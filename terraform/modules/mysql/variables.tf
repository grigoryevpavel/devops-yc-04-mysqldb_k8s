  
variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  sensitive   = true
  validation {
    condition =  var.folder_id !="" || var.folder_id == null
    error_message = "Идентификатор папки не может быть пустым"
  }
}

variable "network_id" {
  type        = string
  description = "Идентификатор сети"
  validation {
    condition =  var.network_id !="" || var.network_id == null
    error_message = "Идентификатор сети не может быть пустым"
  }
} 

variable "name" {
  type        = string
  description = "Название кластера БД"
  validation {
    condition =  var.name !="" || var.name == null
    error_message = "Название кластера не может быть пустым"
  }
} 

variable "environment"{
  type    = string
  default = "PRESTABLE"
  validation {
    condition     = contains(["PRESTABLE","PRODUCTION"], var.environment)
    error_message = "Тип окружения может быть либо PRESTABLE, либо PRODUCTION"
  }  
}

variable "version_sql" {
  type        = string
  description = "Версия сервера. По умолчанию версия '8.0'"
  default     = "8.0"
  validation {
    condition     = contains(["5.7", "8.0"], var.version_sql)
    error_message = "Разрешенные версии 5.7 или 8.0"
  }
} 
variable "mysql_config" {
  type = object({
    sql_mode                      = optional(string)
    max_connections               = optional(number)
    default_authentication_plugin = optional(string)
    innodb_print_all_deadlocks    = optional(bool)
  })
  description = "Конфигурация MYSQL кластера БД. Дополнительно https://terraform-provider.yandexcloud.net/Resources/mdb_mysql_cluster.html#mysql-config"
  default     = null
}

variable "deletion_protection" {
  type        = bool
  description = "Защита от удаления. По умолчанию true"
  default     = true
} 
 
variable "resource_preset_id" {
  type        = string
  description = "Класс хоста. По умолчанию имеет значение 's1.micro'. Что соответствует 2 ядрам, 8 Гб Ram. "
  default     = "s1.micro"
  validation {
    condition     = contains(["s1.micro", "s2.micro", "s1.small", "s2.small", "s1.medium", "s2.medium", "s1.large", "s2.large", "s1.xlarge", "s2.xlarge", "s2.2xlarge", "b1.medium", "b2.medium"], var.resource_preset_id)
    error_message = "Неверный ID класса для хоста MySQL. Разрешены только классы s1.micro, s2.micro, s1.small, s2.small, s1.medium, s2.medium, s1.large, s2.large, s1.xlarge, s2.xlarge, s2.2xlarge, b1.medium, b2.medium"
  }
}

variable "disk_type_id" {
  type        = string
  description = "Тип диска. По умолчанию 'network-ssd'"
  default     = "network-ssd"
  validation {
    condition     = contains(["network-hdd", "network-ssd", "local-ssd", "network-ssd-nonreplicated"], var.disk_type_id)
    error_message = "Неверный тип диска."
  }
}

variable "disk_size" {
  type        = number
  description = "Размер диска в гигобайтах. По умолчанию '20'. https://yandex.cloud/ru/docs/managed-mysql/concepts/limits"
  default     = 20
  validation {
    condition     = var.disk_size >= 10 && var.disk_size <= 6144
    error_message = "Недопустимый размер диска. Размер диска должен быть в пределах между от 10 до 6144 Гб. По умолчанию равен 20 Гб."
  }
}

variable "maintenance_window" {
   type = object({
    type = optional(string)
    day  = optional(string)
    hour = optional(number)
  })
  default = {
    type = "ANYTIME"
    day  = null
    hour = null
  }
  validation {
    condition = (
      (contains(["ANYTIME", "WEEKLY"], var.maintenance_window.type)) &&
      ((var.maintenance_window.day == null && var.maintenance_window.type == "ANYTIME") ? true : (contains(["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"], var.maintenance_window.day)) && var.maintenance_window.type == "WEEKLY") &&
      ((var.maintenance_window.hour == null && var.maintenance_window.type == "ANYTIME") ? true : ((var.maintenance_window.hour >= 1 && var.maintenance_window.hour <= 24)) && var.maintenance_window.type == "WEEKLY")
    )
    error_message = <<EOF
    Неверное значение обслуживания. Если указано ANYTIME, то day и hour должны быть равны null. Если указан тип WEEKLY, то должны быть указаны значения day и hour.
    По умолчанию выбирается произвольное время обслуживания когда собирается статистики, возможно проведение резервного копирования
    EOF
  }
  description = "Начало окна обслуживания."
}
variable "backup_window_start" {
  type = object({
    hours   = optional(number)
    minutes = optional(number)
  })
  default     = {hours=23, minutes=59}
  description = "Время начала проведения резервного копирования"
}

variable "backup_retain_period_days" {
  type        = number
  default     = 7
  description = "Время хранения резервных копий"
  validation {
    condition     = var.backup_retain_period_days == null ? true : (var.backup_retain_period_days >= 7 && var.backup_retain_period_days <= 60)
    error_message = "Неверное значение. Допускаются значения между 7 и 60."
  }
}

variable "restore" {
  type = object({
    backup_id = string
    time      = optional(string)
  })
  default     = null
  description = <<EOF
  Параметры восстановления. По умолчанию не задано и восстановление не происходит.
  backup_id - Индификатор резервной копии, из которой будет происходить восстанвление.
  time      - Время к которому будет происходить восстановление.
  Пример:
  restore = {
    backup_id = "c9qj2tns23432471d9qha:stream_20210122T141717Z"
    time      = "2021-01-23T15:04:05"
  }
  EOF
}

variable "access" {
  type = object({
    data_lens     = optional(bool)
    web_sql       = optional(bool)
    data_transfer = optional(bool)
  })
  default     = { data_lens=true, web_sql=true , data_transfer=false }
  description = <<EOF
  data_lens     - Доступ к Yandex DataLens.
  web_sql       - Доступ к SQL-запросам из консоли websql.
  data_transfer - Доступ к DataTransfer 
  По умолчанию везде доступ включен
  EOF  
}


variable "allow_ingress_v4_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Подключения, с которых разрешен доступ к кластеру БД на порту 3306. По умолчанию разрешены все подключения."

}

variable "default_db"{
  type=object({name=string,username=string,password=string})
  default={name="netology_db",username="user1",password="Fg52341D"}
  description ="БД по умолчанию. Название БД netology_db" 
}

variable "subnets"{
  type=list(object({zone=string,name=optional(string),cidr=optional(string),subnet_id=string})) 
  default=null
  validation {
    condition     = var.subnets != null  
    error_message = "Список подсетей не должен быть пустым"
  }
}  
 