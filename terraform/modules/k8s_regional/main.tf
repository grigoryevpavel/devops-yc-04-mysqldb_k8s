terraform {
  required_providers {
    yandex = { source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13" 
}
resource "yandex_kubernetes_cluster" "k8s-regional" {
  name                    = var.name
  network_id              = var.network_id
  network_policy_provider = var.network_provider
  cluster_ipv4_range = "10.96.0.0/16"
  service_ipv4_range = "10.112.0.0/16"  
  master {
    version   = var.k8s_version
    public_ip = true
    regional {
      region = "ru-central1"
      dynamic "location"{
        for_each=var.subnets
        content{
          zone      = location.value["zone"]
          subnet_id = location.value["subnet_id"]
        }
      } 
    }
    security_group_ids = [yandex_vpc_security_group.k8s-sg.id, yandex_vpc_security_group.k8s-sg-master.id ]
  }
  service_account_id      = yandex_iam_service_account.sa.id
  node_service_account_id = yandex_iam_service_account.sa.id
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_binding.vpc-public-admin,
    yandex_resourcemanager_folder_iam_binding.images-puller,
    yandex_resourcemanager_folder_iam_binding.encrypterDecrypter
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}