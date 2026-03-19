# Contributing Guide

Thank you for your interest in contributing to the Terraform Multi-Cloud DevSecOps platform. This document provides guidelines and instructions for contributing.

## Getting Started

1. **Fork the repository** to your own GitHub account.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/<your-username>/terraform-multi-cloud-devsecops.git
   cd terraform-multi-cloud-devsecops
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/GiulioSavini/terraform-multi-cloud-devsecops.git
   ```

## Branch Naming Convention

Use the following prefixes for your branches:

| Prefix       | Purpose                          |
|--------------|----------------------------------|
| `feature/`   | New features or enhancements     |
| `bugfix/`    | Bug fixes                        |
| `hotfix/`    | Urgent production fixes          |
| `docs/`      | Documentation changes            |
| `refactor/`  | Code refactoring                 |
| `test/`      | Adding or updating tests         |
| `chore/`     | Maintenance and tooling changes  |

Examples:
- `feature/add-gcp-cloud-armor`
- `bugfix/fix-eks-oidc-provider`
- `docs/update-azure-aks-readme`

## Commit Conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/). All commit messages must adhere to the following format:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `build`: Changes that affect the build system or external dependencies
- `ci`: Changes to CI configuration files and scripts
- `chore`: Other changes that do not modify source or test files

### Scopes

Use the module path as the scope, for example:
- `feat(aws/eks): add support for Bottlerocket AMI`
- `fix(azure/networking): correct firewall rule priority`
- `docs(gcp/gke): update usage example`

## Pre-commit Hooks

Pre-commit hooks are **required** for all contributions. Install them before making any changes:

```bash
pip install pre-commit
pre-commit install
```

The following hooks are configured:
- `terraform fmt` - Format Terraform files
- `terraform validate` - Validate Terraform configuration
- `tflint` - Lint Terraform files
- `tfsec` - Static analysis for security issues
- `checkov` - Policy-as-code scanning
- `detect-secrets` - Prevent secrets from being committed
- `markdownlint` - Lint Markdown files

Run all hooks manually:
```bash
pre-commit run --all-files
```

## Pull Request Process

1. **Ensure your branch is up to date** with the main branch:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run all checks locally** before submitting:
   ```bash
   pre-commit run --all-files
   terraform init
   terraform validate
   terraform plan
   ```

3. **Create a Pull Request** against the `main` branch with:
   - A clear title following commit conventions
   - A completed PR template
   - A description of the changes and motivation
   - Links to any related issues

4. **PR Review Requirements**:
   - At least one approving review from a code owner
   - All CI checks must pass
   - No merge conflicts
   - Branch must be up to date with `main`

5. **After approval**, a maintainer will merge using squash-and-merge.

## Code Standards

- All Terraform files must pass `terraform fmt`
- All variables and outputs must be documented with `description`
- All modules must include a `README.md` with usage examples, inputs, and outputs
- All modules must include `versions.tf` with required provider constraints
- Use `snake_case` for all resource and variable names
- Tag all resources with at minimum: `environment`, `project`, `managed_by`

## Reporting Issues

- Use the provided issue templates for bug reports and feature requests
- Search existing issues before creating a new one
- Provide as much detail as possible

## Code of Conduct

Be respectful, inclusive, and constructive. We are committed to providing a welcoming and harassment-free environment for everyone.

## Questions?

Open a discussion or reach out to the maintainers if you have questions about contributing.
