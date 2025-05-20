
resource "yandex_compute_instance" "cluster" {  
  count = 2
  name                      = "node-${count.index}"
  zone                      = "${var.subnet-zone[count.index]}"
  hostname                  = "node-${count.index}"
  allow_stopping_for_update = true
  platform_id = "standard-v2"
  labels = {
    index = "${count.index}"
  }
 
  scheduling_policy {
  preemptible = true  // Прерываемая ВМ
  }

  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.ubuntu.image_id
      type        = "network-hdd"
      size        = "50"
    }
  }

  network_interface {
    
    subnet_id  = "${yandex_vpc_subnet.subnet-zones[count.index].id}"
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "/home/ubuntu/.ssh/id_rsa"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.network_interface[0].nat_ip_address
    }
  }

   provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/.ssh/id_rsa"
    ] 
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host      = self.network_interface[0].nat_ip_address
    }
  }
}

resource "null_resource" "run_ansible_playbook" {
  depends_on = [
    yandex_compute_instance.cluster,
    local_file.inventory_for_k8s_cluster,
    data.external.update_yaml
    ]

  provisioner "local-exec" {
    command = <<EOT
      cd /home/zag1988/CoffeeAndTea/kubespray && \
      ansible-playbook -i /home/zag1988/CoffeeAndTea/kubespray/inventory/mycluster/hosts.yaml --become --become-user=root /home/zag1988/CoffeeAndTea/kubespray/cluster.yml
    EOT
  }
}

# Настройка kubeconfig на удалённой машине
resource "null_resource" "configure_kubeconfig" {
  depends_on = [null_resource.run_ansible_playbook]

  connection {
    type        = "ssh"
    host        = yandex_compute_instance.cluster[0].network_interface.0.nat_ip_address
    user        = "ubuntu" # Подключение как обычный пользователь
    private_key = file("~/.ssh/id_rsa") # Путь к SSH-ключу
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's|server: https://127.0.0.1:6443|server: https://${yandex_compute_instance.cluster[0].network_interface.0.nat_ip_address}:6443|' /root/.kube/config",
      "mkdir -p ~/.kube",
      "sudo cp /etc/kubernetes/admin.conf ~/.kube/config",
      "sudo chown $(id -u):$(id -g) ~/.kube/config",
      "kubectl get pods --all-namespaces"
    ]
  }
}
