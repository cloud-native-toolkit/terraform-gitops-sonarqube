# Gitops Sonarqube

Module to populate a gitops repository to deploy SonarQube.

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform >= v0.15
- kubectl

### Terraform providers

- None

## Module dependencies

This module makes use of the output from other modules:

- GitOps repo - github.com/cloud-native-toolkit/terraform-tools-gitops.git
- Namespace - github.com/cloud-native-toolkit/terraform-gitops-namespace.git

## Example usage

```hcl-terraform
module "gitops_sonarqube" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-sonarqube.git"

  gitops_config            = module.gitops.gitops_config
  git_credentials          = module.gitops.git_credentials
  namespace                = module.gitops_namespace.name
  kubeseal_cert            = module.gitops.sealed_secrets_cert
  server_name              = module.gitops.server_name
}
```

