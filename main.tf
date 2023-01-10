terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8mcvr7idjrbd9kopru"
      size = 80
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  provisioner "file" {
    source      = "./transferer/images.txt"
    destination = "./images.txt"

    connection {
      host        = self.network_interface.0.nat_ip_address
      type        = "ssh"
      user        = var.yc_os_user
      private_key = file(var.private_key_path)
    }
  }

  provisioner "file" {
    source      = "./transferer/fileToYaDisk.sh"
    destination = "./fileToYaDisk.sh"

    connection {
      host        = self.network_interface.0.nat_ip_address
      type        = "ssh"
      user        = var.yc_os_user
      private_key = file(var.private_key_path)
    }
  }



  provisioner "remote-exec" {
#    inline = ["sudo snap install docker","echo 1","sudo groupadd docker","echo 2", "sudo usermod -aG docker $USER","echo 3", "sudo service snap.docker.dockerd start", "echo 4" ,"chmod 777 /home/ubuntu/fileToYaDisk.sh" ,"echo 5", "sudo /home/ubuntu/fileToYaDisk.sh"]
    inline = ["sudo yum -y install docker","echo 1","sudo groupadd docker","echo 2", "sudo usermod -aG docker $USER","echo 3", "echo 4" ,"chmod 777 /home/almalinux/fileToYaDisk.sh" ,"echo 5", "sudo /home/almalinux/fileToYaDisk.sh ${var.yandex_disk_api_token}"]

    connection {
      host        = self.network_interface.0.nat_ip_address
      type        = "ssh"
      user        = var.yc_os_user
      private_key = file(var.private_key_path)
    }
  }

}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}


output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}


output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

