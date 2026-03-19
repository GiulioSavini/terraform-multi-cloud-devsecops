# Security Policy

## Supported Versions

The following versions of this project are currently supported with security updates:

| Version | Supported          |
|---------|--------------------|
| 1.0.x   | Yes                |
| < 1.0   | No                 |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue in this project, please report it responsibly.

### How to Report

1. **Do NOT open a public GitHub issue** for security vulnerabilities.
2. Send an email to **security@giuliosavini.dev** with the following information:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Affected module(s) and version(s)
   - Potential impact assessment
   - Any suggested fixes (optional)

### What to Expect

| Timeframe         | Action                                                  |
|-------------------|---------------------------------------------------------|
| **24 hours**      | Acknowledgment of your report                           |
| **72 hours**      | Initial assessment and severity classification          |
| **7 days**        | Detailed response with remediation plan                 |
| **30 days**       | Fix developed, tested, and released (for critical issues)|
| **90 days**       | Fix released for non-critical issues                    |

### Severity Classification

We use the following severity levels:

- **Critical**: Remote code execution, credential exposure, privilege escalation
- **High**: Unauthorized access to cloud resources, data exposure
- **Medium**: Misconfiguration that weakens security posture
- **Low**: Informational findings, hardening recommendations

### Response Process

1. **Triage**: The security team reviews and classifies the report.
2. **Confirmation**: We confirm the vulnerability and determine affected versions.
3. **Remediation**: A fix is developed and tested internally.
4. **Release**: A patched version is released with a security advisory.
5. **Disclosure**: After the fix is available, the vulnerability is publicly disclosed with credit to the reporter (unless anonymity is requested).

### Scope

The following are in scope for security reports:

- Terraform module configurations that could lead to insecure cloud deployments
- Hardcoded secrets or credentials in any file
- Insecure default values that could lead to data exposure
- Missing encryption configurations
- Overly permissive IAM policies or security group rules
- Container security misconfigurations
- Supply chain vulnerabilities in referenced providers or modules

### Out of Scope

- Vulnerabilities in Terraform itself or cloud provider APIs
- Issues requiring physical access
- Social engineering attacks
- Denial of service against cloud infrastructure (contact your cloud provider)

### Safe Harbor

We support responsible disclosure. If you act in good faith and follow this policy, we will not pursue legal action against you.

## Security Best Practices

When using this project, we recommend:

- Always pin provider and module versions
- Enable state encryption and use remote backends with access controls
- Rotate credentials and use short-lived tokens where possible
- Enable audit logging on all cloud accounts
- Run `tfsec` and `checkov` scans in your CI/CD pipeline
- Review Terraform plans carefully before applying
