terraform {
  required_providers {
    yandex = { source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13" 
}
#создаем облачную сеть
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name 
}
 
#создаем подсети в разных зонах
resource "yandex_vpc_subnet" "subnet" {
  for_each = { for k, v in var.subnets: "${v.name}"=> v } # Сопоставляем каждую подсеть с её уникальным именем
  name           = each.value.name
  zone           = each.value.zone
  network_id     =  yandex_vpc_network.develop.id
  v4_cidr_blocks = [each.value.cidr]
}

