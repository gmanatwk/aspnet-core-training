# Security Tools and References Guide

## 🎯 Overview
This comprehensive guide provides detailed information about security tools, frameworks, and resources essential for ASP.NET Core security implementation and testing.

## 🛠️ Static Application Security Testing (SAST)

### 1. SonarQube
**Purpose**: Code quality and security analysis  
**Language Support**: C#, JavaScript, TypeScript, and 25+ languages  
**Deployment**: Self-hosted or SonarCloud (SaaS)

#### Key Features:
- Security hotspot detection
- OWASP Top 10 vulnerability identification
- Code smell and technical debt analysis
- Quality gate enforcement
- IDE integration

#### Setup and Configuration:
```bash
# Docker deployment
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest

# .NET project analysis
dotnet sonarscanner begin /k:"project-key" /d:sonar.login="your-token"
dotnet build
dotnet sonarscanner end /d:sonar.login="your-token"
```

#### Integration with CI/CD:
```yaml
# Azure DevOps Pipeline
- task: SonarQubePrepare@4
  inputs:
    SonarQube: 'SonarQube'
    scannerMode: 'MSBuild'
    projectKey: 'your-project'
    projectName: 'Your Project'

- task: DotNetCoreCLI@2
  inputs:
    command: 'build'
    projects: '**/*.csproj'

- task: SonarQubeAnalyze@4

- task: SonarQubePublish@4
```

### 2. CodeQL
**Purpose**: Semantic code analysis  
**Developer**: GitHub/Microsoft  
**Language Support**: C#, Java, JavaScript, Python, C++, Go

#### Key Features:
- Deep semantic analysis
- Custom query creation
- GitHub integration
- CVE detection
- Dataflow analysis

#### Setup:
```bash
# Install CodeQL CLI
wget https://github.com/github/codeql-cli-binaries/releases/latest/download/codeql-linux64.zip
unzip codeql-linux64.zip
export PATH=$PATH:/path/to/codeql

# Create database
codeql database create myapp-db --language=csharp --source-root=./src

# Run analysis
codeql database analyze myapp-db codeql/csharp-queries:codeql-suites/csharp-security-and-quality.qls --format=csv --output=results.csv
```

### 3. Checkmarx SAST
**Purpose**: Enterprise-grade static analysis  
**Deployment**: On-premises or cloud  
**Integration**: IDE, CI/CD, and SCM integration

#### Key Features:
- Dataflow analysis
- Business logic vulnerability detection
- Compliance reporting (PCI DSS, OWASP)
- Developer training integration
- False positive learning

### 4. Veracode Static Analysis
**Purpose**: Cloud-based SAST platform  
**Unique Features**: 
- Binary analysis (no source code required)
- Policy-based scanning
- Developer sandbox environment

## 🌐 Dynamic Application Security Testing (DAST)

### 1. OWASP ZAP (Zed Attack Proxy)
**Purpose**: Web application security scanner  
**License**: Open source  
**Automation**: REST API and Python client

#### Key Features:
- Automated and manual testing
- Spider and active scanning
- Fuzzing capabilities
- REST API for automation
- Extensive plugin ecosystem

#### Installation and Basic Usage:
```bash
# Install ZAP
wget https://github.com/zaproxy/zaproxy/releases/download/v2.12.0/ZAP_2_12_0_unix.sh
chmod +x ZAP_2_12_0_unix.sh
./ZAP_2_12_0_unix.sh

# Command line usage
zap.sh -cmd -quickurl https://target.com -quickout report.html

# API automation
zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.disablekey=true
```

#### Python Automation:
```python
from zapv2 import ZAPv2

# Connect to ZAP
zap = ZAPv2(proxies={'http': 'http://127.0.0.1:8080', 'https': 'http://127.0.0.1:8080'})

# Spider target
scan_id = zap.spider.scan('https://target.com')
while int(zap.spider.status(scan_id)) < 100:
    time.sleep(1)

# Active scan
scan_id = zap.ascan.scan('https://target.com')
while int(zap.ascan.status(scan_id)) < 100:
    time.sleep(5)

# Generate report
html_report = zap.core.htmlreport()
```

### 2. Burp Suite Professional
**Purpose**: Comprehensive web security testing platform  
**Developer**: PortSwigger  
**License**: Commercial

#### Key Features:
- Intercepting proxy
- Scanner with custom insertion points
- Intruder for customized attacks
- Repeater for manual testing
- Collaborator for out-of-band testing
- Extensive extension marketplace

#### Extension Recommendations:
- **Logger++**: Enhanced logging
- **Param Miner**: Parameter discovery
- **Backslash Powered Scanner**: Advanced scanning techniques
- **Active Scan++**: Additional scan checks
- **CSRF Scanner**: CSRF vulnerability detection

### 3. Nuclei
**Purpose**: Fast vulnerability scanner  
**Developer**: ProjectDiscovery  
**License**: Open source

#### Key Features:
- Template-based scanning
- High-speed concurrent scanning
- Custom template creation
- CI/CD integration
- Cloud platform support

#### Usage:
```bash
# Install nuclei
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

# Basic scan
nuclei -u https://target.com

# Scan with specific templates
nuclei -u https://target.com -t cves/

# Custom template
nuclei -u https://target.com -t custom-template.yaml
```

### 4. Nikto
**Purpose**: Web server scanner  
**License**: Open source  
**Focus**: Server configuration and known vulnerabilities

#### Usage:
```bash
# Basic scan
nikto -h https://target.com

# Scan with specific plugins
nikto -h https://target.com -Plugins "outdated,headers"

# Output to file
nikto -h https://target.com -o report.html -Format htm
```

## 🔍 Specialized Security Tools

### 1. SQLMap
**Purpose**: SQL injection testing  
**License**: Open source  
**Capabilities**: Database fingerprinting, data extraction, shell access

#### Usage Examples:
```bash
# Basic SQL injection test
sqlmap -u "https://target.com/search?q=test" --batch

# Test POST parameters
sqlmap -u "https://target.com/login" --data="username=admin&password=test" --batch

# Advanced options
sqlmap -u "https://target.com/api/user/1" --technique=BEUSTQ --dbms=postgresql --dump

# Cookie-based testing
sqlmap -u "https://target.com/profile" --cookie="sessionid=abc123" --batch
```

### 2. XSSer
**Purpose**: Cross-site scripting testing  
**License**: Open source  
**Features**: Automatic XSS detection and exploitation

#### Usage:
```bash
# Basic XSS testing
xsser -u "https://target.com/search?q=XSS"

# POST parameter testing
xsser -u "https://target.com/comment" -p "comment=XSS&submit=Post"

# Advanced payload testing
xsser -u "https://target.com/search" --payload="<script>alert('XSS')</script>"
```

### 3. Commix
**Purpose**: Command injection testing  
**License**: Open source  
**Techniques**: Time-based, boolean-based, error-based injection

#### Usage:
```bash
# Basic command injection test
commix -u "https://target.com/ping?host=127.0.0.1"

# POST parameter testing
commix -u "https://target.com/system" --data="command=ls"

# Cookie parameter testing
commix -u "https://target.com/admin" --cookie="admin=true"
```

### 4. OWASP Dependency Check
**Purpose**: Vulnerability scanning for project dependencies  
**License**: Open source  
**Integration**: Maven, Gradle, CLI, Jenkins

#### Usage:
```bash
# Install dependency-check
wget https://github.com/jeremylong/DependencyCheck/releases/download/v7.4.1/dependency-check-7.4.1-release.zip
unzip dependency-check-7.4.1-release.zip

# Scan .NET project
./dependency-check.sh --project "MyProject" --scan ./src --format JSON HTML

# Suppress false positives
./dependency-check.sh --project "MyProject" --scan ./src --suppression suppression.xml
```

## 🛡️ Infrastructure Security Tools

### 1. Nmap
**Purpose**: Network discovery and security auditing  
**License**: Open source  
**Capabilities**: Port scanning, OS detection, service enumeration

#### Common Scans:
```bash
# Basic TCP scan
nmap -sS target.com

# Service version detection
nmap -sV target.com

# OS detection
nmap -O target.com

# Comprehensive scan
nmap -sS -sV -sC -A -O target.com

# Vulnerability scanning
nmap --script vuln target.com

# SSL/TLS testing
nmap --script ssl-enum-ciphers -p 443 target.com
```

### 2. testssl.sh
**Purpose**: SSL/TLS configuration testing  
**License**: Open source  
**Focus**: Cipher suites, protocols, vulnerabilities

#### Usage:
```bash
# Install testssl.sh
git clone https://github.com/drwetter/testssl.sh.git
cd testssl.sh

# Basic SSL test
./testssl.sh https://target.com

# Test specific protocols
./testssl.sh --protocols https://target.com

# Check for vulnerabilities
./testssl.sh --vulnerabilities https://target.com

# Generate JSON output
./testssl.sh --jsonfile results.json https://target.com
```

### 3. SSLyze
**Purpose**: SSL configuration scanner  
**License**: Open source  
**Features**: Python library and command-line tool

#### Usage:
```bash
# Install SSLyze
pip install sslyze

# Basic scan
sslyze target.com

# Specific checks
sslyze --certinfo --tlsv1_2 --http_headers target.com

# JSON output
sslyze --json_out=results.json target.com
```

## 📊 Security Monitoring and SIEM

### 1. Elastic Security (ELK Stack)
**Components**: Elasticsearch, Logstash, Kibana, Beats  
**Purpose**: Security analytics and SIEM  
**License**: Open source and commercial options

#### Setup for Security Monitoring:
```yaml
# docker-compose.yml for ELK stack
version: '3.7'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
      
  kibana:
    image: docker.elastic.co/kibana/kibana:8.5.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
      
  logstash:
    image: docker.elastic.co/logstash/logstash:8.5.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch
```

### 2. Splunk
**Purpose**: Enterprise SIEM platform  
**Deployment**: On-premises, cloud, hybrid  
**Features**: Real-time monitoring, threat hunting, compliance reporting

#### Splunk Search Examples:
```spl
# Failed login attempts
index=security sourcetype=auth | search "failed login" | stats count by user

# SQL injection attempts
index=web | search "union select" OR "' or 1=1" | table _time, src_ip, url, user_agent

# Privilege escalation
index=security | search "privilege" AND "escalation" | timechart span=1h count
```

### 3. Azure Sentinel
**Purpose**: Cloud-native SIEM  
**Integration**: Native Azure services integration  
**Features**: AI-powered analytics, automated response

#### KQL Queries for Security:
```kql
// Failed authentication attempts
SecurityEvent
| where EventID == 4625
| summarize FailedAttempts = count() by Account
| where FailedAttempts > 10

// Suspicious PowerShell activity
SecurityEvent
| where EventID == 4688 and Process contains "powershell"
| where CommandLine contains "bypass" or CommandLine contains "encoded"

// Network anomalies
CommonSecurityLog
| where DeviceEventClassID == "deny"
| summarize DeniedConnections = count() by SourceIP
| where DeniedConnections > 100
```

## 🔐 Cryptographic Tools and Libraries

### 1. OpenSSL
**Purpose**: Cryptographic toolkit  
**License**: Apache-style license  
**Capabilities**: Encryption, digital signatures, certificate management

#### Common Operations:
```bash
# Generate private key
openssl genrsa -out private.key 2048

# Generate certificate signing request
openssl req -new -key private.key -out request.csr

# Generate self-signed certificate
openssl req -x509 -key private.key -out certificate.crt -days 365

# Test SSL connection
openssl s_client -connect target.com:443 -servername target.com

# Verify certificate
openssl verify -CAfile ca.crt certificate.crt
```

### 2. HashiCorp Vault
**Purpose**: Secrets management  
**Features**: Dynamic secrets, encryption as a service, PKI

#### Basic Operations:
```bash
# Start Vault dev server
vault server -dev

# Set secret
vault kv put secret/myapp username=admin password=secret

# Get secret
vault kv get secret/myapp

# Enable database secrets engine
vault auth enable database

# Configure database connection
vault write database/config/my-mysql-database \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(localhost:3306)/" \
    allowed_roles="my-role" \
    username="vault" \
    password="vault-password"
```

### 3. Azure Key Vault
**Purpose**: Cloud-based key and secrets management  
**Integration**: Native Azure services  
**Features**: HSM-backed keys, certificate management, access policies

#### .NET Integration:
```csharp
// Azure Key Vault client setup
var credential = new DefaultAzureCredential();
var client = new SecretClient(new Uri("https://keyvault.vault.azure.net/"), credential);

// Retrieve secret
var secret = await client.GetSecretAsync("database-password");
var connectionString = secret.Value.Value;

// Store secret
await client.SetSecretAsync("api-key", "your-api-key-value");
```

## 📋 Compliance and Assessment Tools

### 1. OWASP ASVS Tools
**Purpose**: Application Security Verification Standard implementation  
**Tools**: Checklist generators, automated testing frameworks

#### ASVS Level Assessment:
```bash
# OWASP ASVS assessment tool
git clone https://github.com/OWASP/ASVS.git
cd ASVS/tools

# Generate checklist
python3 generate_checklist.py --level 2 --format xlsx
```

### 2. CIS Benchmarks
**Purpose**: Security configuration benchmarks  
**Coverage**: Operating systems, cloud platforms, applications

#### CIS-CAT Tool:
```bash
# Download CIS-CAT tool
wget https://workbench.cisecurity.org/files/2419

# Run assessment
./CIS-CAT.sh -a -t windows10 -r /path/to/reports/
```

### 3. NIST Cybersecurity Framework Tools
**Purpose**: Risk assessment and cybersecurity framework implementation  
**Tools**: Assessment questionnaires, maturity models

## 🎓 Training and Learning Platforms

### 1. PortSwigger Web Security Academy
**URL**: https://portswigger.net/web-security  
**Content**: Interactive labs, vulnerability explanations  
**Cost**: Free

#### Lab Categories:
- SQL injection
- Cross-site scripting (XSS)
- Cross-site request forgery (CSRF)
- Authentication vulnerabilities
- Business logic vulnerabilities
- Information disclosure
- Access control vulnerabilities

### 2. OWASP WebGoat
**Purpose**: Deliberately insecure web application for learning  
**License**: Open source  
**Deployment**: Docker, standalone JAR

#### Setup:
```bash
# Docker deployment
docker run -it -p 127.0.0.1:8080:8080 -p 127.0.0.1:9090:9090 -e TZ=Europe/Amsterdam webgoat/goatandwolf

# Standalone JAR
java -Dfile.encoding=UTF-8 -Dwebgoat.port=8080 -Dwebwolf.port=9090 -jar webgoat-server-8.2.2.jar
```

### 3. Damn Vulnerable Web Application (DVWA)
**Purpose**: PHP/MySQL web application with known vulnerabilities  
**License**: Open source  
**Difficulty Levels**: Low, Medium, High

#### Setup:
```bash
# Docker deployment
docker run --rm -it -p 80:80 vulnerables/web-dvwa

# Manual setup
git clone https://github.com/digininja/DVWA.git
# Configure database settings in config/config.inc.php
```

### 4. HackTheBox Academy
**URL**: https://academy.hackthebox.com/  
**Content**: Structured learning paths  
**Focus**: Penetration testing, web application security

## 📚 Documentation and References

### 1. OWASP Resources
#### Core Projects:
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **ASVS**: https://owasp.org/www-project-application-security-verification-standard/
- **Testing Guide**: https://owasp.org/www-project-web-security-testing-guide/
- **Cheat Sheets**: https://cheatsheetseries.owasp.org/

#### Specialized Guides:
- **API Security Top 10**: https://owasp.org/www-project-api-security/
- **Mobile Security**: https://owasp.org/www-project-mobile-security/
- **DevSecOps**: https://owasp.org/www-project-devsecops-guideline/

### 2. Microsoft Security Documentation
#### ASP.NET Core Security:
- **Security Overview**: https://docs.microsoft.com/aspnet/core/security/
- **Authentication**: https://docs.microsoft.com/aspnet/core/security/authentication/
- **Authorization**: https://docs.microsoft.com/aspnet/core/security/authorization/
- **Data Protection**: https://docs.microsoft.com/aspnet/core/security/data-protection/

#### Azure Security:
- **Security Center**: https://docs.microsoft.com/azure/security-center/
- **Key Vault**: https://docs.microsoft.com/azure/key-vault/
- **Sentinel**: https://docs.microsoft.com/azure/sentinel/

### 3. NIST Publications
#### Cybersecurity Framework:
- **Framework Core**: https://www.nist.gov/cyberframework
- **Implementation Guide**: https://nvlpubs.nist.gov/nistpubs/CSWP/NIST.CSWP.04162018.pdf
- **Small Business Guide**: https://nvlpubs.nist.gov/nistpubs/ir/2016/nist.ir.7621r1.pdf

#### Special Publications:
- **SP 800-53**: Security Controls for Federal Information Systems
- **SP 800-63**: Digital Identity Guidelines
- **SP 800-115**: Technical Guide to Information Security Testing

### 4. Industry Standards
#### Payment Card Industry (PCI):
- **PCI DSS**: https://www.pcisecuritystandards.org/
- **PA-DSS**: Payment Application Data Security Standard
- **P2PE**: Point-to-Point Encryption

#### ISO/IEC Standards:
- **ISO 27001**: Information Security Management
- **ISO 27002**: Code of Practice for Information Security Controls
- **ISO 27034**: Application Security

## 🔧 Configuration and Setup Scripts

### 1. Security Tools Installation Script
```bash
#!/bin/bash
# Security tools installation script for Ubuntu/Kali Linux

echo "Installing security testing tools..."

# Update system
apt update && apt upgrade -y

# Install basic tools
apt install -y \
    nmap \
    nikto \
    sqlmap \
    dirb \
    gobuster \
    wfuzz \
    ffuf \
    whatweb \
    wafw00f \
    sublist3r \
    amass \
    subfinder \
    httpx \
    nuclei \
    gf \
    anew \
    qsreplace

# Install Python tools
pip3 install \
    requests \
    beautifulsoup4 \
    selenium \
    scrapy \
    paramiko \
    python-owasp-zap-v2.4 \
    sslyze \
    testssl \
    wapiti3

# Install Go tools
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/tomnomnom/gf@latest
go install -v github.com/tomnomnom/anew@latest

# Install Docker and containers
apt install -y docker.io docker-compose

# Pull useful Docker images
docker pull owasp/zap2docker-stable
docker pull vulnerables/web-dvwa
docker pull webgoat/goatandwolf
docker pull citizenstig/dvwa

echo "Security tools installation completed!"
```

### 2. ASP.NET Core Security Configuration Template
```csharp
// SecurityConfiguration.cs - Template for secure ASP.NET Core setup
public static class SecurityConfiguration
{
    public static void ConfigureSecureDefaults(this IServiceCollection services, IConfiguration configuration)
    {
        // Configure HTTPS
        services.AddHttpsRedirection(options =>
        {
            options.RedirectStatusCode = StatusCodes.Status308PermanentRedirect;
            options.HttpsPort = 443;
        });

        // Configure HSTS
        services.AddHsts(options =>
        {
            options.Preload = true;
            options.IncludeSubDomains = true;
            options.MaxAge = TimeSpan.FromDays(365);
        });

        // Configure antiforgery
        services.AddAntiforgery(options =>
        {
            options.HeaderName = "X-CSRF-TOKEN";
            options.Cookie.Name = "__RequestVerificationToken";
            options.Cookie.HttpOnly = true;
            options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
            options.Cookie.SameSite = SameSiteMode.Strict;
        });

        // Configure data protection
        services.AddDataProtection(options =>
        {
            options.ApplicationDiscriminator = "YourApp";
        })
        .SetDefaultKeyLifetime(TimeSpan.FromDays(90))
        .PersistKeysToAzureKeyVault(
            new Uri(configuration["KeyVault:Uri"]), 
            new DefaultAzureCredential()
        );

        // Configure rate limiting
        services.Configure<IpRateLimitOptions>(configuration.GetSection("IpRateLimiting"));
        services.AddSingleton<IIpPolicyStore, MemoryCacheIpPolicyStore>();
        services.AddSingleton<IRateLimitCounterStore, MemoryCacheRateLimitCounterStore>();
        services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();
    }

    public static void UseSecureDefaults(this IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }
        else
        {
            app.UseExceptionHandler("/Error");
            app.UseHsts();
        }

        // Security headers middleware
        app.UseSecurityHeaders();
        
        // HTTPS redirection
        app.UseHttpsRedirection();
        
        // Rate limiting
        app.UseIpRateLimiting();
        
        // Authentication and authorization
        app.UseAuthentication();
        app.UseAuthorization();
    }
}
```

## 📊 Tool Comparison Matrix

| Tool Category | Tool Name | License | Strengths | Best For |
|---------------|-----------|---------|-----------|----------|
| **SAST** | SonarQube | Open Source/Commercial | CI/CD Integration, Multi-language | Continuous analysis |
| **SAST** | CodeQL | Free | Semantic analysis, Custom queries | Deep code analysis |
| **SAST** | Checkmarx | Commercial | Enterprise features, Compliance | Large organizations |
| **DAST** | OWASP ZAP | Open Source | Automation, API support | CI/CD integration |
| **DAST** | Burp Suite | Commercial | Manual testing, Extensions | Professional testing |
| **DAST** | Nuclei | Open Source | Speed, Template-based | Vulnerability scanning |
| **Database** | SQLMap | Open Source | SQL injection expertise | Database testing |
| **Network** | Nmap | Open Source | Network discovery | Infrastructure assessment |
| **SSL/TLS** | testssl.sh | Open Source | Comprehensive SSL testing | SSL configuration |
| **Dependencies** | OWASP Dependency Check | Open Source | Multi-language support | Dependency scanning |

## 🎯 Tool Selection Guidelines

### For Small Teams/Projects:
- **SAST**: SonarQube Community
- **DAST**: OWASP ZAP
- **Dependencies**: OWASP Dependency Check
- **SSL/TLS**: testssl.sh

### For Enterprise Environments:
- **SAST**: SonarQube Enterprise + CodeQL
- **DAST**: Burp Suite Professional + OWASP ZAP
- **SIEM**: Splunk or Azure Sentinel
- **Secrets Management**: HashiCorp Vault or Azure Key Vault

### For CI/CD Integration:
- **SAST**: SonarQube, CodeQL Actions
- **DAST**: OWASP ZAP, Nuclei
- **Container Security**: Trivy, Clair
- **Infrastructure**: Terraform security scanning

## 🚀 Getting Started Checklist

### Immediate Actions (Week 1):
- [ ] Install OWASP ZAP for basic security testing
- [ ] Set up SonarQube for code analysis
- [ ] Configure dependency scanning in your build pipeline
- [ ] Implement basic security headers

### Short-term Goals (Month 1):
- [ ] Establish security testing in CI/CD pipeline
- [ ] Implement comprehensive SAST and DAST scanning
- [ ] Set up security monitoring and logging
- [ ] Train team on security tools and practices

### Long-term Objectives (Quarter 1):
- [ ] Achieve comprehensive security coverage
- [ ] Establish security metrics and KPIs
- [ ] Implement advanced threat detection
- [ ] Regular security assessments and penetration testing

---

**Last Updated**: December 2024  
**Version**: 1.0  
**Maintained By**: Security Engineering Team

**Remember**: Tools are only as effective as the people using them. Invest in training and understanding alongside tool implementation! 🛡️
