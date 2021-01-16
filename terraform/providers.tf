# Configure the Google provider
# For auth, the provider can either use the system-wide google auth, or
# a Service Account's JSON auth via:
#   export GOOGLE_APPLICATION_CREDENTIALS={{path}}
provider "google" {
  project = var.project
  region  = "europe-west1"
}
