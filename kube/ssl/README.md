```
helm template --namespace cert-manager -n cert-manager . | kubectl apply -f -
```
