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

variable   "public_key"   {
  type = string 
  sensitive = true
} 

variable   "account_name"   {
  type = string  
  default = "k8s-sa"
  validation {
    condition =  var.account_name !="" || var.account_name == null
    error_message = "Имя сервисного аккаунта не должно быть пустым"
  }
}

variable "kms_key_name" {
  type        = string
  description = "Ключ Yandex Key Management Service для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи."
  default     = "k8s_key"
} 

variable "name" {
  type        = string
  description = "Название k8s кластера"
  default     = "develop"
  validation {
    condition =    var.name!=null  
    error_message = "Не задано название кластера."
  }
} 

variable "k8s_version" {
  type        = string
  description = "Версия k8s. Разрешены версии 1.27, 1.28, 1.29. По уомлчанию используется версия 1.28"
  validation {
    condition =  contains(["1.27", "1.28", "1.29"], var.k8s_version)  
    error_message = "Недопустимая версия k8s. Разрешены версии 1.27, 1.28, 1.29."
  }
  default = "1.28"
} 

variable "subnets"{
  type=list(object({zone=string,name=string, subnet_id=string,cidr=string})) 
  default=null
  validation {
    condition =    var.subnets!=null  
    error_message = "Не задан список подсетей."
  }
  
  validation {
    condition =   length(var.subnets)==3  
    error_message = "Для регионального кластера требуется 3 подсети, по 1 в каждой зоне доступности."
  }
} 

variable "scalepolicy"{
  type    = object({  
    type=string
    size=optional(number)
    max=optional(number)
    min=optional(number)
    initial=optional(number)
  })
  default = {type="autoscale",max=6,min=3,initial=3}
} 

variable "node_acceleration"{
  type         = string
  description  = "Тип ускорения сети. Возможные значения: standard(без повышенной производительности) и software-accelerated(с повышенной производительностью)"
  default      = "standard"
  validation {
    condition =  var.node_acceleration!=null &&  contains(["standard","software-accelerated"], var.node_acceleration)  
    error_message = "Неверный тип ускорения сети. Разрешено использовать только значения standard или software-accelerated"
  }
}

variable "node_platform"{
  type        = string
  description = "Платформа на которой будут разворачиваться узлы. Определяет тип используемых ядер. standard-v1 соответвует Intel Broadwell(e5-2660), standard-v2 соответствует Intel Cascade Lake, standard-v3 соответствует Intel Ice Lake"
  default     = "standard-v2"
  validation {
    condition =  var.node_platform!=null &&  contains(["standard-v2","standard-v3"], var.node_platform)  
    error_message = "Неверная платформа. Разрешено использовать только значения standard-v2 или standard-v3"
  }
}

variable "network_provider"{
  type        = string
  description = "Провайдер сети"
  default     = "CALICO"
}

# Ресурсы узлов
variable "vms_resources"{ 
  type = map
  default={ 
        worker={  
            cores       = 2
            memory      = 2 # Разрешенные значения для платформы standard-v2: от 2 до 64 Гб с шагом 2 Гб  
            preemptible = true
            public_ip   = true
            disk = {
               type = "network-hdd"
               size = 64 # минимум 64 Гб для standard-v2
            }
        }
    }
} 