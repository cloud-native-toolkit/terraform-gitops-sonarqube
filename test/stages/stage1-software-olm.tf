module "dev_software_olm" {
  source = "github.com/cloud-native-toolkit/terraform-k8s-olm"

  cluster_config_file      = module.dev_cluster.config_file_path
  cluster_version          = module.dev_cluster.version
  cluster_type             = var.cluster_type
}