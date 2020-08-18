Step 1: install the CRDs

```
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.0.0-alpha.1/cert-manager.crds.yaml
kubectl create ns cert-manager
```

Step 2: install the chart (note: needs Helm 3)

```
helm upgrade --namespace cert-manager cert-manager .
```
