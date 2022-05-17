
resource null_resource write_outputs {
  provisioner "local-exec" {
    command = "echo \"$${OUTPUT}\" > gitops-output.json"

    environment = {
      OUTPUT = jsonencode({
        name        = module.gitops_sonarqube.name
        branch      = module.gitops_sonarqube.branch
        namespace   = module.gitops_sonarqube.namespace
        server_name = module.gitops_sonarqube.server_name
        layer       = module.gitops_sonarqube.layer
        layer_dir   = module.gitops_sonarqube.layer == "infrastructure" ? "1-infrastructure" : (module.gitops_sonarqube.layer == "services" ? "2-services" : "3-applications")
        type        = module.gitops_sonarqube.type
        postgresql  = module.gitops_sonarqube.postgresql
      })
    }
  }
}
