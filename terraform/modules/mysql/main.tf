terraform {
  required_providers {
    yandex = { source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13" 
}
resource "yandex_mdb_mysql_cluster" "mysql" {
  name                = var.name 
  folder_id           = var.folder_id
  environment         = var.environment
  network_id          = var.network_id 
  version             = var.version_sql
  security_group_ids  =  [yandex_vpc_security_group.mysql.id]  
  deletion_protection = var.deletion_protection

  resources {
    resource_preset_id = var.resource_preset_id
    disk_type_id       = var.disk_type_id
    disk_size          = var.disk_size
  } 

  database {
    name = var.default_db.name
  }

  user {
    name     = var.default_db.username
    password = var.default_db.password
    permission {
      database_name = var.default_db.name
      roles         = ["ALL"]
    }
  }

  dynamic "host" {
    for_each = var.subnets 
    content {
      zone             =   host.value["zone"] 
      subnet_id        =   host.value["subnet_id"] 
      name             = "${var.name}-db-${host.key+1}"
      priority         = host.key * 10
      assign_public_ip = false
      backup_priority  = host.key
    }
  }

  dynamic "host" {
    for_each = var.subnets 
    content {
      zone             =   host.value["zone"] 
      subnet_id        =   host.value["subnet_id"] 
      name             = "${var.name}-dbrep-${host.key+1}"
      priority         = host.key * 10
      assign_public_ip = false
      replication_source_name = "${var.name}-db-${host.key+1}"
    }
  }

  mysql_config = var.mysql_config == null ? {} : {
    sql_mode                      = lookup(var.mysql_config, "sql_mode", "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION")
    max_connections               = lookup(var.mysql_config, "max_connections", 100)
    default_authentication_plugin = lookup(var.mysql_config, "default_authentication_plugin", "MYSQL_NATIVE_PASSWORD")
    innodb_print_all_deadlocks    = lookup(var.mysql_config, "innodb_print_all_deadlocks", true)
  }

  dynamic "maintenance_window" {
    for_each = [var.maintenance_window]
    content {
      type = lookup(maintenance_window.value, "type", "ANYTIME")
      day  = lookup(maintenance_window.value, "day", null)
      hour = lookup(maintenance_window.value, "hour", null)
    }
  }

  dynamic "backup_window_start" {
    for_each = var.backup_window_start == null ? [] : [var.backup_window_start]
    content {
      hours   = lookup(backup_window_start.value, "hours", null)
      minutes = lookup(backup_window_start.value, "minutes", null)
    }
  }

  backup_retain_period_days = var.backup_retain_period_days

  dynamic "restore" {
    for_each = var.restore == null ? [] : [var.restore]
    content {
      backup_id = restore.value["backup_id"]
      time      = lookup(restore.value, "time", null)
    }
  }

  dynamic "access" {
    for_each = var.access == null ? [] : [var.access]
    content {
      data_lens     = lookup(access.value, "data_lens", true)
      web_sql       = lookup(access.value, "web_sql", true)
      data_transfer = lookup(access.value, "data_transfer", false)
    }
  } 
}