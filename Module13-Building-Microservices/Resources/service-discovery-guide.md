# Service Discovery Guide (Continued)

## 🔗 Tools and Technologies

### Open Source
- **Consul** - HashiCorp's service discovery solution
- **Eureka** - Netflix's service registry
- **etcd** - Distributed key-value store for service discovery
- **Zookeeper** - Apache's coordination service
- **Kubernetes DNS** - Built-in service discovery for Kubernetes

### Cloud Platforms
- **AWS Service Discovery** - AWS Cloud Map
- **Azure Service Fabric** - Microsoft's microservices platform
- **Google Cloud Service Directory** - Google's service registry
- **Istio Service Mesh** - Advanced service mesh with discovery

### Implementation Examples

#### Consul Integration
```csharp
public class ConsulServiceRegistry : IServiceRegistry
{
    private readonly IConsulClient _consul;
    private readonly ILogger<ConsulServiceRegistry> _logger;

    public ConsulServiceRegistry(IConsulClient consul, ILogger<ConsulServiceRegistry> logger)
    {
        _consul = consul;
        _logger = logger;
    }

    public async Task RegisterServiceAsync(ServiceInstance instance)
    {
        var registration = new AgentServiceRegistration
        {
            ID = instance.Id,
            Name = instance.ServiceName,
            Address = instance.Host,
            Port = instance.Port,
            Tags = instance.Metadata?.Select(kvp => $"{kvp.Key}={kvp.Value}").ToArray(),
            Check = new AgentServiceCheck
            {
                HTTP = $"http://{instance.Host}:{instance.Port}/health",
                Interval = TimeSpan.FromSeconds(30),
                Timeout = TimeSpan.FromSeconds(10),
                DeregisterCriticalServiceAfter = TimeSpan.FromMinutes(5)
            }
        };

        await _consul.Agent.ServiceRegister(registration);
        _logger.LogInformation("Registered service {ServiceName} with ID {ServiceId}", 
            instance.ServiceName, instance.Id);
    }

    public async Task DeregisterServiceAsync(string serviceId)
    {
        await _consul.Agent.ServiceDeregister(serviceId);
        _logger.LogInformation("Deregistered service with ID {ServiceId}", serviceId);
    }

    public async Task<List<ServiceInstance>> GetHealthyInstancesAsync(string serviceName)
    {
        var services = await _consul.Health.Service(serviceName, string.Empty, true);
        
        return services.Response.Select(entry => new ServiceInstance
        {
            Id = entry.Service.ID,
            ServiceName = entry.Service.Service,
            Host = entry.Service.Address,
            Port = entry.Service.Port,
            Status = InstanceStatus.Healthy,
            Metadata = entry.Service.Tags?.ToDictionary(tag => 
                tag.Split('=')[0], tag => tag.Split('=')[1]) ?? new Dictionary<string, string>()
        }).ToList();
    }
}

// Startup configuration
public void ConfigureServices(IServiceCollection services)
{
    services.AddConsul(options =>
    {
        options.Address = new Uri("http://localhost:8500");
    });
    
    services.AddSingleton<IServiceRegistry, ConsulServiceRegistry>();
}
```

#### Kubernetes Service Discovery
```csharp
public class KubernetesServiceDiscovery : IServiceDiscovery
{
    private readonly IKubernetes _kubernetes;
    private readonly ILogger<KubernetesServiceDiscovery> _logger;

    public async Task<List<ServiceInstance>> DiscoverServicesAsync(string serviceName)
    {
        try
        {
            var endpoints = await _kubernetes.ListNamespacedEndpointsAsync("default", 
                labelSelector: $"app={serviceName}");

            var instances = new List<ServiceInstance>();
            
            foreach (var endpoint in endpoints.Items)
            {
                if (endpoint.Subsets != null)
                {
                    foreach (var subset in endpoint.Subsets)
                    {
                        if (subset.Addresses != null)
                        {
                            foreach (var address in subset.Addresses)
                            {
                                var port = subset.Ports?.FirstOrDefault()?.Port ?? 80;
                                instances.Add(new ServiceInstance
                                {
                                    Id = $"{address.Ip}:{port}",
                                    ServiceName = serviceName,
                                    Host = address.Ip,
                                    Port = port,
                                    Status = InstanceStatus.Healthy
                                });
                            }
                        }
                    }
                }
            }

            return instances;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to discover services for {ServiceName}", serviceName);
            return new List<ServiceInstance>();
        }
    }
}
```

## 📈 Advanced Patterns

### Service Mesh Integration
```csharp
public class ServiceMeshAwareDiscovery : IServiceDiscovery
{
    private readonly IServiceRegistry _registry;
    private readonly IConfiguration _configuration;

    public async Task<List<ServiceInstance>> DiscoverServicesAsync(string serviceName)
    {
        // Check if running in service mesh
        if (_configuration.GetValue<bool>("ServiceMesh:Enabled"))
        {
            // In service mesh, use DNS-based discovery
            return new List<ServiceInstance>
            {
                new ServiceInstance
                {
                    ServiceName = serviceName,
                    Host = serviceName, // Service mesh handles resolution
                    Port = 80,
                    Status = InstanceStatus.Healthy
                }
            };
        }
        
        // Fallback to traditional service registry
        return await _registry.GetHealthyInstancesAsync(serviceName);
    }
}
```

### Multi-Region Service Discovery
```csharp
public class MultiRegionServiceDiscovery : IServiceDiscovery
{
    private readonly Dictionary<string, IServiceRegistry> _regionRegistries;
    private readonly ILoadBalancer _regionLoadBalancer;
    private readonly string _currentRegion;

    public async Task<List<ServiceInstance>> DiscoverServicesAsync(string serviceName)
    {
        var allInstances = new List<ServiceInstance>();
        
        // First, try current region
        var currentRegionRegistry = _regionRegistries[_currentRegion];
        var localInstances = await currentRegionRegistry.GetHealthyInstancesAsync(serviceName);
        
        // Prioritize local instances
        foreach (var instance in localInstances)
        {
            instance.Weight = 100; // Higher weight for local instances
            allInstances.Add(instance);
        }
        
        // If no local instances, try other regions
        if (!localInstances.Any())
        {
            foreach (var (region, registry) in _regionRegistries)
            {
                if (region != _currentRegion)
                {
                    var remoteInstances = await registry.GetHealthyInstancesAsync(serviceName);
                    foreach (var instance in remoteInstances)
                    {
                        instance.Weight = 10; // Lower weight for remote instances
                        instance.Metadata["region"] = region;
                        allInstances.Add(instance);
                    }
                }
            }
        }
        
        return allInstances;
    }
}
```

### Cache-Enabled Service Discovery
```csharp
public class CachedServiceDiscovery : IServiceDiscovery
{
    private readonly IServiceDiscovery _innerDiscovery;
    private readonly IMemoryCache _cache;
    private readonly TimeSpan _cacheExpiry = TimeSpan.FromMinutes(1);

    public async Task<List<ServiceInstance>> DiscoverServicesAsync(string serviceName)
    {
        var cacheKey = $"service-discovery:{serviceName}";
        
        if (_cache.TryGetValue(cacheKey, out List<ServiceInstance> cachedInstances))
        {
            return cachedInstances;
        }
        
        var instances = await _innerDiscovery.DiscoverServicesAsync(serviceName);
        
        _cache.Set(cacheKey, instances, _cacheExpiry);
        
        return instances;
    }
}
```

## 🧪 Testing Service Discovery

### Unit Testing
```csharp
public class ServiceDiscoveryTests
{
    [Test]
    public async Task DiscoverServicesAsync_ShouldReturnHealthyInstances()
    {
        // Arrange
        var mockRegistry = new Mock<IServiceRegistry>();
        var expectedInstances = new List<ServiceInstance>
        {
            new ServiceInstance 
            { 
                Id = "1", 
                ServiceName = "test-service", 
                Host = "localhost", 
                Port = 8080,
                Status = InstanceStatus.Healthy 
            }
        };
        
        mockRegistry.Setup(r => r.GetHealthyInstancesAsync("test-service"))
                   .ReturnsAsync(expectedInstances);
        
        var discovery = new ClientSideServiceDiscovery(mockRegistry.Object, null, null);
        
        // Act
        var result = await discovery.DiscoverServicesAsync("test-service");
        
        // Assert
        Assert.AreEqual(1, result.Count);
        Assert.AreEqual("test-service", result[0].ServiceName);
    }
}
```

### Integration Testing
```csharp
public class ServiceDiscoveryIntegrationTests : IClassFixture<TestServerFixture>
{
    private readonly TestServerFixture _fixture;

    public ServiceDiscoveryIntegrationTests(TestServerFixture fixture)
    {
        _fixture = fixture;
    }

    [Test]
    public async Task ServiceRegistration_ShouldBeDiscoverable()
    {
        // Arrange
        var registry = _fixture.ServiceProvider.GetRequiredService<IServiceRegistry>();
        var discovery = _fixture.ServiceProvider.GetRequiredService<IServiceDiscovery>();
        
        var instance = new ServiceInstance
        {
            Id = Guid.NewGuid().ToString(),
            ServiceName = "integration-test-service",
            Host = "localhost",
            Port = 9999,
            Status = InstanceStatus.Healthy
        };
        
        // Act
        await registry.RegisterServiceAsync(instance);
        var discoveredInstances = await discovery.DiscoverServicesAsync("integration-test-service");
        
        // Assert
        Assert.Contains(discoveredInstances, i => i.Id == instance.Id);
        
        // Cleanup
        await registry.DeregisterServiceAsync(instance.Id);
    }
}
```

### Load Testing Service Discovery
```csharp
public class ServiceDiscoveryLoadTests
{
    [Test]
    public async Task ServiceDiscovery_ShouldHandleHighConcurrency()
    {
        var discovery = new ClientSideServiceDiscovery(/* dependencies */);
        var tasks = new List<Task>();
        var successCount = 0;
        var totalRequests = 1000;
        
        for (int i = 0; i < totalRequests; i++)
        {
            tasks.Add(Task.Run(async () =>
            {
                try
                {
                    await discovery.DiscoverServicesAsync("load-test-service");
                    Interlocked.Increment(ref successCount);
                }
                catch (Exception ex)
                {
                    // Log exception
                }
            }));
        }
        
        await Task.WhenAll(tasks);
        
        // Assert at least 95% success rate
        Assert.IsTrue(successCount >= totalRequests * 0.95);
    }
}
```

## 📊 Monitoring Service Discovery

### Metrics Collection
```csharp
public class InstrumentedServiceDiscovery : IServiceDiscovery
{
    private readonly IServiceDiscovery _innerDiscovery;
    private readonly IMetricsCollector _metrics;
    private readonly ILogger<InstrumentedServiceDiscovery> _logger;

    public async Task<List<ServiceInstance>> DiscoverServicesAsync(string serviceName)
    {
        var stopwatch = Stopwatch.StartNew();
        var success = false;
        var instanceCount = 0;
        
        try
        {
            var instances = await _innerDiscovery.DiscoverServicesAsync(serviceName);
            instanceCount = instances.Count;
            success = true;
            return instances;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Service discovery failed for {ServiceName}", serviceName);
            _metrics.Increment("service_discovery_errors_total", 
                new[] { ("service_name", serviceName) });
            throw;
        }
        finally
        {
            stopwatch.Stop();
            
            _metrics.Histogram("service_discovery_duration_ms", stopwatch.ElapsedMilliseconds,
                new[] { ("service_name", serviceName), ("success", success.ToString()) });
            
            if (success)
            {
                _metrics.Gauge("discovered_instances_count", instanceCount,
                    new[] { ("service_name", serviceName) });
            }
        }
    }
}
```

### Health Monitoring Dashboard
```json
{
  "dashboard": {
    "title": "Service Discovery Monitoring",
    "panels": [
      {
        "title": "Service Discovery Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, service_discovery_duration_ms_bucket)",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "Healthy Service Instances",
        "type": "stat",
        "targets": [
          {
            "expr": "sum by (service_name) (discovered_instances_count)",
            "legendFormat": "{{service_name}}"
          }
        ]
      },
      {
        "title": "Service Discovery Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(service_discovery_errors_total[5m])",
            "legendFormat": "Error Rate"
          }
        ]
      }
    ]
  }
}
```

## 🔐 Security Considerations

### Secure Service Registry Access
```csharp
public class SecureServiceRegistry : IServiceRegistry
{
    private readonly IServiceRegistry _innerRegistry;
    private readonly ITokenValidator _tokenValidator;

    public async Task RegisterServiceAsync(ServiceInstance instance)
    {
        var token = GetAuthenticationToken();
        if (!await _tokenValidator.ValidateAsync(token))
        {
            throw new UnauthorizedAccessException("Invalid authentication token");
        }
        
        // Encrypt sensitive metadata
        if (instance.Metadata.ContainsKey("database-connection"))
        {
            instance.Metadata["database-connection"] = 
                await EncryptAsync(instance.Metadata["database-connection"]);
        }
        
        await _innerRegistry.RegisterServiceAsync(instance);
    }
}
```

### mTLS for Service Communication
```csharp
public class SecureHttpClientFactory
{
    public HttpClient CreateSecureClient(string targetService)
    {
        var handler = new HttpClientHandler();
        
        // Configure client certificate
        var clientCert = LoadClientCertificate();
        handler.ClientCertificates.Add(clientCert);
        
        // Configure server certificate validation
        handler.ServerCertificateCustomValidationCallback = 
            (sender, certificate, chain, errors) =>
            {
                return ValidateServerCertificate(certificate, targetService);
            };
        
        return new HttpClient(handler);
    }
}
```

## 🚀 Migration Strategies

### Gradual Migration from Hardcoded URLs
```csharp
public class HybridServiceDiscovery : IServiceDiscovery
{
    private readonly IServiceDiscovery _dynamicDiscovery;
    private readonly IConfiguration _configuration;

    public async Task<List<ServiceInstance>> DiscoverServicesAsync(string serviceName)
    {
        // Check if service has hardcoded configuration
        var hardcodedUrl = _configuration[$"Services:{serviceName}:Url"];
        if (!string.IsNullOrEmpty(hardcodedUrl))
        {
            var uri = new Uri(hardcodedUrl);
            return new List<ServiceInstance>
            {
                new ServiceInstance
                {
                    ServiceName = serviceName,
                    Host = uri.Host,
                    Port = uri.Port,
                    Status = InstanceStatus.Healthy
                }
            };
        }
        
        // Fallback to dynamic discovery
        return await _dynamicDiscovery.DiscoverServicesAsync(serviceName);
    }
}
```

### Blue-Green Deployment Support
```csharp
public class BlueGreenServiceDiscovery : IServiceDiscovery
{
    public async Task<List<ServiceInstance>> DiscoverServicesAsync(string serviceName)
    {
        var allInstances = await _registry.GetServiceInstancesAsync(serviceName);
        
        // Filter by deployment color based on traffic routing rules
        var activeColor = await GetActiveDeploymentColor(serviceName);
        
        return allInstances
            .Where(i => i.Metadata.GetValueOrDefault("deployment-color") == activeColor)
            .ToList();
    }
    
    private async Task<string> GetActiveDeploymentColor(string serviceName)
    {
        // Check traffic routing configuration
        var routingConfig = await _configService.GetRoutingConfigAsync(serviceName);
        return routingConfig.ActiveColor;
    }
}
```

## 📋 Checklist for Production

### Before Going Live
- [ ] Service registry is highly available
- [ ] Health checks are comprehensive and fast
- [ ] Load balancing strategy is tested under load
- [ ] Circuit breakers are configured for registry calls
- [ ] Monitoring and alerting are in place
- [ ] Security policies are enforced
- [ ] Graceful shutdown procedures are tested
- [ ] Disaster recovery procedures are documented

### Operational Readiness
- [ ] Runbooks for common scenarios
- [ ] Automated deployment procedures
- [ ] Service discovery performance benchmarks
- [ ] Capacity planning based on service count
- [ ] Network connectivity requirements documented
- [ ] Security scanning and vulnerability management

## 🎯 Summary

Service discovery is a critical component of microservices architecture that enables:

1. **Dynamic Configuration** - Services can be deployed and scaled without manual configuration
2. **Fault Tolerance** - Unhealthy instances are automatically removed from rotation
3. **Load Distribution** - Traffic is balanced across available instances
4. **Operational Efficiency** - Reduced manual intervention and configuration management

Choose the right pattern based on your:
- **Infrastructure complexity**
- **Team expertise** 
- **Scalability requirements**
- **Operational constraints**

Remember: Start simple and evolve your service discovery strategy as your system grows in complexity.

---

*For more advanced topics, see the [Microservices Design Patterns](./microservices-design-patterns.md) guide.*