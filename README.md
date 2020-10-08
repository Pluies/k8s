k8s!
====

This repo is the infrastructure-as-code for my Kubernetes cluster.

It contains two major parts:

Terraform
---------

[Terraform](https://www.terraform.io/) is used to set up the Google Cloud side of
things, mainly around setting up the GKE cluster itself and setting up firewalls
as needed.

You'll need to create a [GCloud storage bucket](https://cloud.google.com/storage/docs/creating-buckets) in the [Google Cloud Console](https://console.cloud.google.com/storage/browser)
to store the Terraform state file.

Once this bucket is created, you can initialise the repository. In the `terraform/`
folder, run:

```sh
# Ensure you're logged into gcloud
gcloud auth application-default login
# Then initialise the repo & backend
terraform init -backend-config bucket=name-of-the-bucket-created-above
```

To run terraform, from the `terraform/` folder:

```sh
# List differences between plan and reality:
terraform plan

# Apply the changes:
terraform apply
```

Kubefiles
---------

Once the GKE cluster is up and running, we need to install everything we need on
it. One way to do so is raw yaml kubefiles, but I've grown used to [Helm](https://helm.sh/)
and I really like the templating support and auto-ordering of elements (so that
a ConfigMap gets applied before the Deployment that relies on it, regardless of
whether it's before it in the file or not).

Helm 2 used to require a server-side component, Tiller, which was a bit heavy.
Thankfully, Helm 3 did away with Tiller, and we can now manage everything through
Helm!

To install things:

- Create the namespaces:
```
kubectl apply -f kube/namespaces.yaml
```

- Install DNS management:
```
helm upgrade --install --namespace dns dns kube/dns/
```

- Install cert-manager for TLS certificates:
```
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.0.0-alpha.1/cert-manager.crds.yaml
helm upgrade --install --namespace cert-manager cert-manager kube/ssl/
```

- Install the web apps:
```
helm upgrade --install --namespace web web kube/web/
```
