FROM docker.io/alpine/k8s:1.28.5

RUN set -x && \
    AVP_VERSION=$(curl -sI https://github.com/argoproj-labs/argocd-vault-plugin/releases/latest | sed -n -e 's;^location: https://.*/v;;p' | tr -d '\r') && \
    curl -sL -o argocd-vault-plugin "https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v${AVP_VERSION}/argocd-vault-plugin_${AVP_VERSION}_linux_amd64" && \
    chmod +x argocd-vault-plugin && \
    mv argocd-vault-plugin /usr/bin/argocd-vault-plugin
