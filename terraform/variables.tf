variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
  sensitive   = true
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  sensitive   = true
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  sensitive   = true
}

variable   "public_key"   {
  type = string 
  sensitive = true
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}


variable "vpc_mysql_name" {
  type        = string
  default     = "mysqlnet"
  description = "имя сети"
}  
variable "vpc_mysql_subnets"{
  type=list(object({zone=string,name=string,cidr=string})) 
  default=[
    { zone = "ru-central1-a", name="private-0", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", name="private-1", cidr = "10.0.2.0/24" }]
}
 
variable "mysql_name"{
  type        = string
  description = "Название кластера Mysql"
  default     = "cluster-mysql"
  nullable    = false
}

variable "mysql_environment"{
  type    = string
  default = "PRESTABLE"
  validation {
    condition     = contains(["PRESTABLE","PRODUCTION"], var.mysql_environment)
    error_message = "Тип окружения может быть либо PRESTABLE, либо PRODUCTION"
  }  
}

variable "mysql_version_sql" {
  type        = string
  description = "Версия сервера БД. По умолчанию версия '8.0'"
  default     = "8.0"
  validation {
    condition     = contains(["5.7", "8.0"], var.mysql_version_sql)
    error_message = "Разрешенные версии 5.7 или 8.0"
  }
}  

variable "mysql_preset_id" {
  type        = string
  description = "Класс хоста. По умолчанию имеет значение 'b1.medium'. Что соответствует 2 ядрам Inter Broadwell с 50% нагрузкой, 4 Гб Ram. "
  default     = "b1.medium"
  validation {
    condition     = contains(["s1.micro", "s2.micro", "s1.small", "s2.small", "s1.medium", "s2.medium", "s1.large", "s2.large", "s1.xlarge", "s2.xlarge", "s2.2xlarge", "b1.medium", "b2.medium"], var.mysql_preset_id)
    error_message = "Неверный ID класса для хоста MySQL. Разрешены только классы s1.micro, s2.micro, s1.small, s2.small, s1.medium, s2.medium, s1.large, s2.large, s1.xlarge, s2.xlarge, s2.2xlarge, b1.medium, b2.medium"
  }
}

variable "mysql_disk_type_id" {
  type        = string
  description = "Тип диска. По умолчанию 'network-ssd'"
  default     = "network-ssd"
  validation {
    condition     = contains(["network-hdd", "network-ssd", "local-ssd", "network-ssd-nonreplicated"], var.mysql_disk_type_id)
    error_message = "Неверный тип диска."
  }
}

variable "mysql_disk_size" {
  type        = number
  description = "Размер диска в гигобайтах. По умолчанию 20 Гб. https://yandex.cloud/ru/docs/managed-mysql/concepts/limits"
  default     = 20
  validation {
    condition     = var.mysql_disk_size >= 10 && var.mysql_disk_size <= 6144
    error_message = "Недопустимый размер диска. Размер диска должен быть в пределах между от 10 до 6144 Гб. По умолчанию равен 20 Гб."
  }
}

variable "mysql_deletion_protection"{
  type     = bool
  description = "Защита от удаления. По умолчанию true"
  default     = true
}

variable "mysql_default_db"{
  type=object({name=string,username=string,password=string})
  default={name="netology_db",username="user1",password="Fg52341D"}
  description ="БД по умолчанию. Название БД  по умолчанию - netology_db" 
} 

variable "vpc_k8s_name" {
  type        = string
  default     = "k8snet"
  description = "имя сети"
}  
variable "vpc_k8s_subnets"{
  type=list(object({zone=string,name=string,cidr=string})) 
  default=[
    { zone = "ru-central1-a", name="public-0", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", name="public-1", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-d", name="public-2", cidr = "10.0.3.0/24" }
  ]
}