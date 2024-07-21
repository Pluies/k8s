# Set up the cluster and its node pool
resource "google_container_cluster" "cluster" {
  name               = "easternkube"
  location           = "us-east1-c"
  min_master_version = "1.29"

  # Choose how quickly you'd like new features!
  release_channel {
    # RAPID, REGULAR or STABLE - going middle of the road here
    channel = "REGULAR"
  }

  # Whitelist the following CIDR block to connect to the Kubernetes API
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.allowed_cidr
    }
  }

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

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  # See https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html#node-pool-management
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "preemptible_nodes" {
  name       = "preemptible-nodes"
  location   = "us-east1-c"
  cluster    = google_container_cluster.cluster.name
  node_count = 2

  node_config {
    # Let's try the new types!
    machine_type = "e2-small"

    # Ensure we're using containerd-based images to work with GKE 1.24+
    image_type = "COS_CONTAINERD"

    # More cost-saving: preemptible instances are cheaper
    preemptible = true

    # More cost-saving: 30GB total storage is included in the always-free tier
    disk_size_gb = 15

    # TODO find out what this does
    metadata = {
      "disable-legacy-endpoints" = "true"
    }

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
