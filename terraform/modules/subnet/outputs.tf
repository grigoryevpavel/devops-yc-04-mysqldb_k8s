output "subnets" {
   value = [ for k , v in var.subnets: {zone= v.zone, name = v.name, cidr=v.cidr, subnet_id=yandex_vpc_subnet.subnet["${v.name}"].id } ]
}
output "network_id"{
   value = yandex_vpc_network.develop.id
}