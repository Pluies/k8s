k8s!
====

This repo is the infrastructure-as-code for my Kubernetes cluster.

It contains two major parts:

Terraform
---------

[Terraform](https://www.terraform.io/) is used to set up the Google Cloud side of
things, mainly around setting up the GKE cluster itself and setting up firewalls
as needed.

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

In order to apply the various bits, go into one of the subfolders of `kube/` and
follow the README!
