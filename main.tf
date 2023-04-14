terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}


# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create a new Web Droplet in the nyc1 region
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.terraform-ssh.id]
}

# Chave SSH
data "digitalocean_ssh_key" "terraform-ssh" {
  name = var.name_ssh
}

# Cluster kubernets
resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = "k8s"
  region  = var.region
  version = "1.26.3-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

# Variables
variable "do_token" {
  default = ""
}

variable "name_ssh" {
  default = ""
}

variable "region" {
  default = ""
}

#output IP droplet
output "jenkins_ip" {
    value = digitalocean_droplet.jenkins.ipv4_address
}

# Output kube_config em formato arquivo

resource "local_file" "kuber_config" {
  content  = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  filename = "kube_config.yaml"
}

