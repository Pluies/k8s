# Configure the Google provider
provider "google" {
  project = var.project
  region  = "europe-west1"
}

# Set up the cluster and its node pool
resource "google_container_cluster" "cluster" {
  name               = "easternkube"
  location           = "us-east1-c"
  min_master_version = "1.17"

  # Choose how quickly you'd like new features!
  release_channel {
    channel = "RAPID"
    # Other options are REGULAR or STABLE
  }

  # Whitelist the following CIDR block to connect to the Kubernetes API
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.allowed_cidr
    }
  }

  # We'll run a zonal cluster in order to withstand the loss of a single zone
  # This will create three node pools (one per zone) containing 1 instance each
  # Note: to benefit from the always-free tier on instances, use the following regions:
  # - Oregon: us-west1
  # - Iowa: us-central1
  # - South Carolina: us-east1
  # See https://cloud.google.com/free/docs/gcp-free-tier

  # Disable addons for cost-savings
  addons_config {

    # HTTP Load-Balancing would be an extra $18 a month, let's disable it and
    # use an nginx DaemonSet instead
    http_load_balancing {
      disabled = true
    }
  }

  # Disable StackDriver / logging
  logging_service = "none"
  # Disable monitoring too
  monitoring_service = "none"

  master_auth {
    username = var.kube_username
    password = var.kube_password
  }

  node_pool {
    # Per-zone node count
    node_count = 2

    management {
      auto_repair  = true
      auto_upgrade = true
    }

    node_config {
      # Cost-saving: `f1-micro` is the smallest possible instance type... But doesn't work anymore.
      machine_type = "g1-small"

      # More cost-saving: preemptible instances are cheaper
      preemptible = true

      # More cost-saving: 30GB total storage is included in the always-free tier
      disk_size_gb = 10

      oauth_scopes = [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/trace.append",
        "https://www.googleapis.com/auth/ndev.clouddns.readwrite", # Manage DNS from k8s
      ]
    }
  }
}

# Open ports 80 and 443 on our nodes for web hosting
resource "google_compute_firewall" "web" {
  name    = "web"
  network = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# Create a DNS zone to contain the DNS record to our cluster
# NB: this is not free, each managed zone costs $0.20 per month
resource "google_dns_managed_zone" "zone" {
  name     = "kube"
  dns_name = var.domain
  dnssec_config {
    state = "off"
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
