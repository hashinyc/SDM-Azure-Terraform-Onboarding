module "strongdm_onboarding" {
  source = "./onboarding"

  # Prefix will be added to resource names
  prefix = "az-tf-sdm"
  location = var.REGION_AZURE

  # EKS resources take approximately 20 min
  # NOTE: Before creating AKS resources, set up Service Principal by following these instructions https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli
  # create_aks               = true, set up a service
  # Mysql resources take approximately 5 min
  # create_mysql             = true
  # RDP resources take approximately 10 min
  # create_rdp               = true
  # HTTP resources take approximately 5 min
  # NOTE: Before creating HTTP resources, set up TLS here https://app.strongdm.com/app/datasources/websites
  # create_http              = false
  # SSH resources take approximately 5 min
  # create_ssh              = true
  # Gateways take approximately 5 min
  # create_strongdm_gateways = true

  # VPC creation takes approximately 5 min
  # If set to false the default VPC will be used instead
  # create_resource_group = true

  # Tags will be added to strongDM and AWS resources.
  # tags = {}
}
