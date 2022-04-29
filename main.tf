locals {
  bin_dir = module.setup_clis.bin_dir
  tmp_dir      = "${path.cwd}/.tmp/sonarqube"
  yaml_dir    = "${local.tmp_dir}/chart/sonarqube"
  ingress_host = "${var.hostname}-${var.namespace}.${var.cluster_ingress_hostname}"
  ingress_url  = "https://${local.ingress_host}"
  service_url  = "http://sonarqube-sonarqube.${var.namespace}:9000"
  values_file = "values-${var.server_name}.yaml"

  layer = "services"
  application_branch = "main"
  name = "sonarqube"
  path = "sonarqube"
  admin_password = "admin"

  global_config    = {
    storageClass = var.storage_class
    clusterType = var.cluster_type
    ingressSubdomain = var.cluster_ingress_hostname
  }
  sonarqube_config = {
    image = {
      pullPolicy = "Always"
    }
    persistence = {
      enabled = false
    }
    serviceAccount = {
      create = false
      name = var.service_account_name
    }
    podLabels = {
      "app.kubernetes.io/part-of" = "sonarqube"
    }
    postgresql = {
      enabled = true
      postgresqlServer = ""
      postgresqlDatabase = "sonarDB"
      postgresqlUsername = "sonarUser"
      postgresqlPassword = "sonarPass"
      service = {
        port = 5432
      }
      serviceAccount = {
        enabled = false
        name = var.service_account_name
      }
      persistence = {
        enabled = false
      }
      volumePermissions = {
        enabled = false
      }
      master = {
        labels = {
          "app.kubernetes.io/part-of" = "sonarqube"
        }
        podLabels = {
          "app.kubernetes.io/part-of" = "sonarqube"
        }
      }
    }
    ingress = {
      enabled = false
    }
    plugins = {
      install = var.plugins
    }
    enableTests = false
    OpenShift = {
      enabled = true
      createSCC = false
    }
  }
  postgresql = var.postgresql != null ? var.postgresql : {
    username      = "sonarUser"
    password      = "sonarPass"
    hostname      = ""
    port          = 5432
    database_name = "sonarDB"
    external      = false
  }
  postgresql_external = lookup(local.postgresql, "external", false)
  sonarqube_server_config = {
    persistence = {
      enabled = var.persistence
      storageClass = var.storage_class
    }
    postgresql = {
      enabled = !local.postgresql_external
      postgresqlServer = lookup(local.postgresql, "hostname", "")
      postgresqlDatabase = lookup(local.postgresql, "database_name", "sonarDB")
      postgresqlUsername = lookup(local.postgresql, "username", "sonarUser")
      postgresqlPassword = lookup(local.postgresql, "password", "sonarPass")
      service = {
        port = lookup(local.postgresql, "port", 5432)
      }
      serviceAccount = {
        enabled = false
        name = var.service_account_name
      }
      persistence = {
        enabled = var.persistence
        storageClass = var.storage_class
      }
    }
    ingress = {
      enabled = var.cluster_type == "kubernetes"
      annotations = {
        "kubernetes.io/ingress.class" = "nginx"
        "nginx.ingress.kubernetes.io/proxy-body-size" = "20m"
        "ingress.kubernetes.io/proxy-body-size" = "20M"
        "ingress.bluemix.net/client-max-body-size" = "20m"
      }
      hosts = [{
        name = local.ingress_host
      }]
      tls = [{
        secretName = var.tls_secret_name
        hosts = [
          local.ingress_host
        ]
      }]
    }
    OpenShift = {
      enabled = var.cluster_type != "kubernetes"
      createSCC = false
    }
  }
  ocp_route_config       = {
    nameOverride = "sonarqube"
    targetPort = "http"
    app = "sonarqube"
    serviceName = "sonarqube-sonarqube"
    termination = "edge"
    insecurePolicy = "Redirect"
    consoleLink = {
      enabled = true
      section = "Cloud-Native Toolkit"
      displayName = "SonarQube"
      imageUrl = "data:image/png;base64,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"
    }
  }

  values_content = {
    sonarqube = local.sonarqube_config
    ocp-route = local.ocp_route_config
  }
  values_server_content = {
    global = local.global_config
  }
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource setup_chart {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${local.service_url}' '${var.namespace}' '${local.values_file}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
      VALUES_SERVER_CONTENT = yamlencode(local.values_server_content)
      KUBESEAL_CERT = var.kubeseal_cert
      ADMIN_PASSWORD = local.admin_password
      TMP_DIR = local.tmp_dir
    }
  }
}

module "service_account" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-service-account.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  name = var.service_account_name
  sccs = ["anyuid", "privileged"]
  server_name = var.server_name
  rbac_rules = [{
    apiGroups = [""]
    resources = ["configmaps","endpoints","events","persistentvolumeclaims","pods","secrets","serviceaccounts","services"]
    verbs = ["*"]
  },{
    apiGroups = ["apps"]
    resources = ["daemonsets","deployments","statefulsets","replicasets"]
    verbs = ["*"]
  },{
    apiGroups = ["apps"]
    resources = ["deployments/finalizers"]
    verbs = ["update"]
  },{
    apiGroups = ["extensions"]
    resources = ["deployments"]
    verbs = ["*"]
  },{
    apiGroups = [""]
    resources = ["namespaces"]
    verbs = ["get"]
  },{
    apiGroups = ["policy"]
    resources = ["podsecuritypolicies","poddisruptionbudgets"]
    verbs = ["*"]
  },{
    apiGroups = ["rbac.authorization.k8s.io"]
    resources = ["clusterrolebindings","clusterroles","rolebindings","roles"]
    verbs = ["*"]
  },{
    apiGroups = ["batch"]
    resources = ["jobs"]
    verbs = ["*"]
  },{
    apiGroups = ["monitoring.coreos.com"]
    resources = ["servicemonitors"]
    verbs = ["get","create"]
  },{
    apiGroups = ["charts.helm.k8s.io"]
    resources = ["*"]
    verbs = ["*"]
  },{
    apiGroups = ["networking.istio.io"]
    resources = ["gateways","virtualservices"]
    verbs = ["*"]
  },{
    apiGroups = ["cert-manager.io"]
    resources = ["certificates"]
    verbs = ["*"]
  },{
    apiGroups = ["route.openshift.io"]
    resources = ["routes","routes/custom-host"]
    verbs = ["*"]
  },{
    apiGroups = ["security.openshift.io"]
    resourceNames = ["gitops-sonarqube-sonarqube-sonarqube-anyuid","gitops-sonarqube-sonarqube-sonarqube-privileged"]
    resources = ["securitycontextconstraints"]
    verbs = ["use"]
  }
  ]
  rbac_cluster_scope = true

}

module setup_group_scc {
  depends_on = [module.service_account]

  source = "github.com/cloud-native-toolkit/terraform-gitops-sccs.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  service_account = ""
  sccs = ["anyuid"]
  server_name = var.server_name
  group = true
}


resource null_resource setup_gitops {
  depends_on = [null_resource.setup_chart, module.service_account,module.setup_group_scc]

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = "base"
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}' --cascadingDelete=false"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
