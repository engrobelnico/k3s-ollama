# moteur IA pour tester un chat bot basée sur les données opensearch

User Question → LLM (embed) → OpenSearch kNN search → Context → LLM (generate) → Answer

## les composants utilisés

| Composant | Helm chart | Namespace |
|---|---|---|
| Ollama (LLM local) | ollama-helm | ollama |
| Flowise (RAG builder / interface chat) | custom | ollama |

## pipeline RAG

otel-logs-* (texte brut)
       ↓  Setup Job (PostSync)
otel-rag-vectors (kNN index avec embeddings nomic-embed-text)
       ↓  Similarity search
Flowise → Ollama (génération réponse)

## accès

- Flowise : `http://flowise.kube.local`
- Login : admin / (voir secret `flowise-auth` dans le namespace ollama)

## to rotate password

```bash
sudo kubectl patch secret flowise-auth -n ollama \
  --type=merge -p '{"stringData":{"password":"NewPass!"}}'
```

