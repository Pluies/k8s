# Configure the Google provider
provider "google" {
  project = "${var.project}"
  region  = "europe-west1"
}

# Set up the cluster and its node pool
resource "google_container_cluster" "cluster" {
  name               = "kubernetes-cluster"
  zone               = "europe-west1"
  min_master_version = "1.11"

  master_authorized_networks_config {}

  additional_zones = [
    "europe-west1-d",
    "europe-west1-b",
    "europe-west1-c",
  ]

  # Disable addons for cost-savings
  addons_config {
    http_load_balancing {
      disabled = true
    }
    kubernetes_dashboard {
      disabled = true
    }
  }

  # Disable StackDriver / logging
  logging_service = "none"

  master_auth {
    username = "${var.kube_username}"
    password = "${var.kube_password}"
  }

  node_pool {
    # Per-zone node count
    node_count = 1

    management {
      auto_repair  = true
      auto_upgrade = true
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
