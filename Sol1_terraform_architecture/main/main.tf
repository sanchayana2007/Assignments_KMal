provider "google" {
  project     = var.var_project
}
module "vpc" {
  source = "../modules/Global_environ" 
  env                   = var.var_env
  company               = var.var_company
 
  var_public_subnet = var.ue1_public_subnet
  var_private_subnet= var.ue1_private_subnet
}
module "ELB" {
  source                = "../modules/ELB"
  network_self_link     = module.vpc.out_vpc_self_link
  subnetwork1           = module.uc1.uc1_out_public_subnet_name
  env                   = var.var_env
  company               = var.var_company
  var_public_subnet = var.uc1_public_subnet
  var_private_subnet= var.uc1_private_subnet
  
}
module "LBInternal" {
  source                = "../modules/LBInternal"
  network_self_link     = module.vpc.out_vpc_self_link
  subnetwork1           = module.ue1.ue1_out_public_subnet_name
  env                   = var.var_env
  company               = var.var_company
  var_public_subnet = var.ue1_public_subnet
  var_private_subnet= var.ue1_private_subnet
}
module "DATABASE" {
  source                = "../modules/DATABASE"
  network_self_link     = module.vpc.out_vpc_self_link
  subnetwork1           = module.ue1.ue1_out_public_subnet_name
  env                   = var.var_env
  company               = var.var_company
  
  var_private_subnet= var.private_subnet
}


######################################################################
# Display Output Public Instance
######################################################################
output "public_address"  { value = module.ELB.pub_address}
output "private_address" { value = module.LBInternal.pri_address}

output "vpc_self_link" { value = module.vpc.out_vpc_self_link}
