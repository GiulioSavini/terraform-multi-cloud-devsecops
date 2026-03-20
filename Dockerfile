FROM ubuntu:22.04

LABEL maintainer="DevSecOps Team"
LABEL description="Multi-cloud DevSecOps workspace with Terraform, Kubernetes, and security tools"

ARG TERRAFORM_VERSION=1.7.5
ARG TERRAGRUNT_VERSION=0.55.18
ARG KUBECTL_VERSION=1.29.3
ARG HELM_VERSION=3.14.3
ARG TFLINT_VERSION=0.50.3
ARG TFSEC_VERSION=1.28.5
ARG CHECKOV_VERSION=3.2.39
ARG INFRACOST_VERSION=0.10.33
ARG LINKERD_VERSION=stable-2.14.10

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    jq \
    git \
    unzip \
    wget \
    python3 \
    python3-pip \
    bash-completion \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Terraform
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin/ \
    && rm /tmp/terraform.zip

# Terragrunt
RUN curl -fsSL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
    -o /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt

# kubectl
RUN curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Helm
RUN curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    | tar xz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && rm -rf /tmp/linux-amd64

# TFLint
RUN curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" \
    -o /tmp/tflint.zip \
    && unzip /tmp/tflint.zip -d /usr/local/bin/ \
    && rm /tmp/tflint.zip

# tfsec
RUN curl -fsSL "https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-amd64" \
    -o /usr/local/bin/tfsec \
    && chmod +x /usr/local/bin/tfsec

# Checkov
RUN pip3 install --no-cache-dir checkov==${CHECKOV_VERSION}

# Infracost
RUN curl -fsSL "https://github.com/infracost/infracost/releases/download/v${INFRACOST_VERSION}/infracost-linux-amd64.tar.gz" \
    | tar xz -C /tmp \
    && mv /tmp/infracost-linux-amd64 /usr/local/bin/infracost \
    && chmod +x /usr/local/bin/infracost

# AWS CLI v2
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o /tmp/awscliv2.zip \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# Azure CLI (via APT repository with GPG key verification)
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | tee /usr/share/keyrings/microsoft.gpg > /dev/null \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ jammy main" \
    > /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends azure-cli \
    && rm -rf /var/lib/apt/lists/*

# Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update && apt-get install -y --no-install-recommends google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

# Linkerd CLI
RUN curl -fsSL "https://github.com/linkerd/linkerd2/releases/download/${LINKERD_VERSION}/linkerd2-cli-${LINKERD_VERSION}-linux-amd64" \
    -o /usr/local/bin/linkerd \
    && chmod +x /usr/local/bin/linkerd

# Pre-commit
RUN pip3 install --no-cache-dir pre-commit

# terraform-docs
RUN curl -fsSL "https://terraform-docs.io/dl/v0.17.0/terraform-docs-v0.17.0-linux-amd64.tar.gz" \
    | tar xz -C /tmp \
    && mv /tmp/terraform-docs /usr/local/bin/ \
    && chmod +x /usr/local/bin/terraform-docs

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
