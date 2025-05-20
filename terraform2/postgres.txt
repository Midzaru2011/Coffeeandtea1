resource "yandex_compute_instance" "postgres" {
  name                      = "postgres-node"
  zone                      = var.subnet-zone[0] # Используем первую зону доступности
  hostname                  = "postgres-node"
  allow_stopping_for_update = true
  platform_id               = "standard-v2"

  scheduling_policy {
    preemptible = true # Прерываемая ВМ
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
    subnet_id = yandex_vpc_subnet.subnet-zones[0].id # Используем первую подсеть
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  # Установка PostgreSQL и создание базы данных
  provisioner "remote-exec" {
  inline = [
    <<EOT
      sudo apt-get update -y
      sudo apt-get install -y postgresql postgresql-contrib
      sudo sed -i 's/^#listen_addresses =.*/listen_addresses = '\''*'\''/' /etc/postgresql/*/main/postgresql.conf
      echo 'host    all             all             0.0.0.0/0               md5' | sudo tee -a /etc/postgresql/*/main/pg_hba.conf
      sudo systemctl restart postgresql
      sudo -u postgres psql -c "CREATE DATABASE \"CoffeeAndTea\";"
      sudo -u postgres psql -c "CREATE USER sasha WITH PASSWORD 'password';"
      sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"CoffeeAndTea\" TO sasha;"
    EOT
  ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.network_interface[0].nat_ip_address
    }
  }
}
