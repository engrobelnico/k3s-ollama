#!/bin/bash

set -o errexit

main () {
    myNamespace=ollama
    NS=$(sudo kubectl get namespace $myNamespace --ignore-not-found);
    if [[ "$NS" ]]; then
        echo "Skipping creation of namespace $myNamespace - already exists";
    else
        echo "Creating namespace $myNamespace";
        sudo kubectl create namespace $myNamespace;
    fi;

    # Copy OpenSearch credentials secret into ollama namespace
    echo "Copying opensearch-admin-password secret to ollama namespace..."
    sudo kubectl get secret opensearch-admin-password -n opensearch -o json \
      | python3 -c "import sys,json; d=json.load(sys.stdin); d['metadata']={'name':d['metadata']['name'],'namespace':'ollama'}; print(json.dumps(d))" \
      | sudo kubectl apply -f - || echo "Secret already exists or opensearch not deployed yet"

    # Deploy via ArgoCD
    sudo kubectl apply -n argocd -f ollama.yaml

    # Sync ArgoCD application
    argocd login kube.local:443 --grpc-web-root-path /argocd-server --insecure \
      --username admin \
      --password $(sudo kubectl -n argocd get secret argocd-initial-admin-secret \
        -o jsonpath="{.data.password}" | base64 -d)
    argocd app sync ollama

    echo ""
    echo "Open WebUI available at: http://kube.local/ollama"
    echo ""
    echo "Model pull in progress... check with:"
    echo "  sudo kubectl logs -n ollama deployment/ollama -f"
}

main "$@"
