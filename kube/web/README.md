Create the namespace and install the web assets:
```
kubectl create ns web
helm upgrade --install --namespace web web .
```

Note: relies on CRDs from `../ssl`!
