resource "yandex_kubernetes_node_group" "k8s_nodes" { 
  for_each   =  { for k,v in var.subnets: k=>v}
  cluster_id = yandex_kubernetes_cluster.k8s-regional.id
  name       = "${var.name}-${each.value.name}"
  version    = var.k8s_version

  instance_template { 
    platform_id               = var.node_platform
    network_acceleration_type = var.node_acceleration
    container_runtime {
     type = "containerd"
    } 
    metadata = {
      "ssh-keys" = var.public_key
    }
    network_interface {
      nat                = var.vms_resources.worker.public_ip
      subnet_ids         = [each.value.subnet_id]
      security_group_ids = [yandex_vpc_security_group.k8s-sg.id,yandex_vpc_security_group.k8s-sg-worker.id]
    }
    resources {
      memory = var.vms_resources.worker.memory
      cores  = var.vms_resources.worker.cores
    }
    boot_disk {
      type = var.vms_resources.worker.disk.type
      size = var.vms_resources.worker.disk.size
    }
    scheduling_policy {
      preemptible = var.vms_resources.worker.preemptible
    }
  }
  
  scale_policy {
    dynamic "fixed_scale"{
        for_each = var.scalepolicy.type=="fixed_scale"?[var.scalepolicy.size]:[]
        content{
            size = fixed_scale.value
        }
    }
    dynamic "auto_scale"{
        for_each = var.scalepolicy.type=="autoscale"? [{
              min=var.scalepolicy.min>0?var.scalepolicy.min:1
              max=var.scalepolicy.max>0?var.scalepolicy.max:1
              initial=var.scalepolicy.initial>0?var.scalepolicy.initial:1
             }]:[]
        content{
            min     = auto_scale.value.min
            max     = auto_scale.value.max
            initial = auto_scale.value.initial
        }
    } 
  }
  allocation_policy {
    location {
      zone = each.value.zone
    }
  }
}