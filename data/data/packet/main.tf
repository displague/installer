provider "packet" {
  auth_token = var.packet_auth_token
}

terraform {
  required_providers {
    packet = "~> 3.0.0"
  }
}

provider "cloudflare" {
  email   = var.packet_cf_email
  api_key = var.packet_cf_api_key
}

module "bastion" {

  source               = "./modules/bootstrap"
  auth_token           = var.auth_token
  project_id           = var.project_id
  facility             = var.facility
  plan                 = var.plan_master
  operating_system     = var.bastion_operating_system
  ssh_private_key_path = var.ssh_private_key_path
  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  cf_zone_id           = var.cf_zone_id
  ocp_version          = var.ocp_version
  ocp_version_zstream  = var.ocp_version_zstream
  //depends              = [module.prepare_openshift.finished]
}

module "dns_lb" {
  source = "./modules/dns"

  cluster_name       = var.cluster_name
  cluster_basedomain = var.cluster_basedomain
  cf_zone_id         = var.cf_zone_id
  node_type          = "lb"
  node_ips           = tolist([module.bastion.lb_ip])
}

module "prepare_openshift" {

  source = "./modules/prereq"

  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  ocp_version          = var.ocp_version
  count_master         = var.count_master
  count_compute        = var.count_compute
  ssh_public_key_path  = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path
  bastion_ip           = module.bastion.lb_ip
  ocp_api_token        = var.ocp_cluster_manager_token
  depends              = [module.bastion.finished]
}

module "openshift_install" {
  source = "./modules/install"

  ssh_private_key_path = var.ssh_private_key_path
  operating_system     = var.bastion_operating_system
  bastion_ip           = module.bastion.lb_ip
  count_master         = var.count_master
  count_compute        = var.count_compute
  cluster_name         = var.cluster_name
  cluster_basedomain   = var.cluster_basedomain
  bootstrap_ip         = module.openshift_bootstrap.node_ip
  master_ips           = module.openshift_masters.node_ip
  worker_ips           = module.openshift_workers.node_ip
  depends              = [module.openshift_masters.node_ip, module.openshift_workers.node_ip]

  ocp_storage_nfs_enable    = var.ocp_storage_nfs_enable
  ocp_storage_ocs_enable    = var.ocp_storage_ocs_enable
  ocp_virtualization_enable = var.ocp_virtualization_enable
}