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

I'll be organising each namespace as its own Helm chart, but won't be using Tiller,
the server-side of Helm, as it's a bit heavy for our tiny tiny cluster.

So, in order to apply these, go into one of the subfolders of `kube/` and run:

```bash
helm template . | kubectl apply -f -
```

Note: this means we lose two of the big selling points of Helm: rollbacks and
deletion of resources.

Deletion of resources could be achived through tactical use of the `--prune`
flag, but given we do one-chart-per-namespace, we could also delete the whole
namespace and start again.

Rollbacks would have to be done by reapplying the previous version from Git.
