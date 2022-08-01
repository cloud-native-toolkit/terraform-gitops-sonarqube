
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  sensitive = true
  description = "The credentials for the gitops repo(s)"
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "cluster_ingress_hostname" {
  type        = string
  description = "Ingress hostname of the IKS cluster."
  default     = ""
}

variable "cluster_type" {
  type        = string
  description = "The cluster type (openshift or ocp3 or ocp4 or kubernetes)"
  default     = "ocp4"
}

variable "tls_secret_name" {
  type        = string
  description = "The name of the secret containing the tls certificate values"
  default     = ""
}

variable "storage_class" {
  type        = string
  description = "The storage class to use for the persistent volume claim"
  default     = ""
}

variable "service_account_name" {
  description = "The name of the service account that should be used for the deployment"
  type        = string
  default     = "sonarqube-sonarqube"
}

variable "plugins" {
  description = "The list of plugins that will be installed on SonarQube"
  type        = list(string)
  default     = [
    "https://github.com/checkstyle/sonar-checkstyle/releases/download/4.33/checkstyle-sonar-plugin-4.33.jar",
    "https://github.com/AmadeusITGroup/sonar-stash/releases/download/1.6.0/sonar-stash-plugin-1.6.0.jar"
  ]
}

variable "postgresql" {
  type = object({
    username      = string
    password      = string
    hostname      = string
    port          = string
    database_name = string
    external      = bool
  })
  description = "Properties for an existing postgresql database"
  default     = null
}

variable "hostname" {
  type        = string
  description = "The hostname that will be used for the ingress/route"
  default     = "sonarqube"
}

variable "persistence" {
  type        = bool
  description = "Flag indicating that persistence should be enabled for the pods"
  default     = false
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "cluster_version" {
  type        = string
  description = "The cluster version"
  default     = ""
}



