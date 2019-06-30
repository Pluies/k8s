```
helm template --namespace web -n ambassador . | kubectl -nweb apply -f -
```
