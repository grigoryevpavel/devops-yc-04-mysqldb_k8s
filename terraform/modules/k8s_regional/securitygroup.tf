resource "yandex_vpc_security_group" "k8s-sg" {
  name        = "k8s-sg"
  description = "Правила группы обеспечивают базовую работоспособность кластера Managed Service for Kubernetes. Применяется к кластеру и группам узлов."
  network_id  = var.network_id

  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие под-под, сервис-сервис. Включает подсеть подов и сервисов."
    v4_cidr_blocks    = ["10.96.0.0/16","10.112.0.0/16"] 
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}

resource "yandex_vpc_security_group" "k8s-sg-master" {
  name        = "k8s-sg-master"
  description = "Правила группы обеспечивают доступ к мастер-узлам"
  network_id  = var.network_id
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера Managed Service for Kubernetes и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к api k8s"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  } 
}

resource "yandex_vpc_security_group" "k8s-sg-worker" {
  name        = "k8s-sg-worker"
  description = "Правила группы обеспечивают доступ к рабочим узлам"
  network_id  = var.network_id
  
  ingress {
    protocol       = "ANY"
    description    = "Правило разрешает все соединения"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  } 
}

