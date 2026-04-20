# moteur IA pour tester un chat bot basée sur les données opensearch

User Question → LLM (embed) → OpenSearch kNN search → Context → LLM (generate) → Answer

## les composants utilisés 
Composant	Helm chart	Namespace
Ollama (LLM local)	ollama-helm	ollama
Open WebUI (interface chat)	open-webui	ollama
LangChain app (orchestration)	custom	rag

otel-logs-* (texte brut)
       ↓  Reindex Job
rag-logs (kNN index avec embeddings)
       ↓  Similarity search
Open WebUI → Ollama (génération réponse)

Après git push et déploiement, dans Open WebUI → Workspace > Knowledge → ajouter la collection rag-logs comme source RAG.

## to rotate password

sudo kubectl patch secret open-webui-admin -n ollama \
  --type=merge -p "{\"data\":{\"password\":\"$(echo -n 'NewPass!' | base64)\"}}"

