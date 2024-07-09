Deploy services across multiple clusters with one command

Ideally, I would like to be able to use this command:
```
kubectl apply -k https://github.com/gmarcy/homelab-argocd/argocd/overlays/$CLUSTER_NAME
```

Unfortunately the kustomize run under the covers isn't passed the
--enable-helm option which is needed to bootstrap ArgoCD now that
I am using the argo-helm deployment instead of using the install.yaml
approach.

Anyway, for now need to run:
```
kustomize build --enable-helm https://github.com/gmarcy/homelab-argocd/argocd/overlays/$CLUSTER_NAME | kubectl apply -f -
```

That's all for now
