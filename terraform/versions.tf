terraform {
  backend "gcs" {
    prefix = "terraform/tfstate.json"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
  required_version = ">= 0.13"
}
