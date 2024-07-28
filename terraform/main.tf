module "mysql_subnet" {
  source           = "./modules/subnet"
  vpc_name         = var.vpc_mysql_name
  subnets          = var.vpc_mysql_subnets
}
module "mysql_cluster" {
  source              = "./modules/mysql"
  folder_id           = var.folder_id
  network_id          = module.mysql_subnet.network_id 
  subnets             = module.mysql_subnet.subnets 
  name                = var.mysql_name 
  environment         = var.mysql_environment 
  version_sql         = var.mysql_version_sql

  resource_preset_id  = var.mysql_preset_id
  disk_type_id        = var.mysql_disk_type_id 
  disk_size           = var.mysql_disk_size 

  deletion_protection = var.mysql_deletion_protection 

  default_db          = var.mysql_default_db

  maintenance_window = {
    type = "ANYTIME"
  }

  backup_window_start = {
    hours   = 23
    minutes = 59
  }

  access = {
    web_sql = true
  }
  
}

module "k8s_subnet" {
  source           = "./modules/subnet"
  vpc_name         = var.vpc_k8s_name
  subnets          = var.vpc_k8s_subnets
}

module "k8s_cluster"{
  source           = "./modules/k8s_regional"
  folder_id        = var.folder_id
  public_key       = var.public_key
  network_id       = module.k8s_subnet.network_id
  subnets          = module.k8s_subnet.subnets 
  k8s_version      = "1.29"
}