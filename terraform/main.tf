provider "google" {
  project = "${var.project}"
  region  = "europe-west1"
}

resource "google_container_cluster" "cluster" {
  name                 = "standard-cluster-1"
  zone                 = "europe-west1"
  initial_node_count   = 0

  ip_allocation_policy = {
    cluster_ipv4_cidr_block = "10.32.0.0/14"
  }

  master_authorized_networks_config {}

  additional_zones = [
    "europe-west1-b",
    "europe-west1-c",
    "europe-west1-d",
  ]

  master_auth {
    username = "${var.kube_username}"
    password = "${var.kube_password}"
  }

  node_config {
    disk_size_gb = 10
    preemptible  = true
    machine_type = "f1-micro"

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}

resource "google_container_node_pool" "np" {
  name       = "default-pool"
  region     = "europe-west1"
  cluster    = "${google_container_cluster.cluster.name}"
  node_count = 1
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.cluster.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.cluster.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.cluster.master_auth.0.cluster_ca_certificate}"
}
