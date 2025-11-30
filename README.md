# 📊 PRISMA-2020 API (Python)

API em Python (FastAPI) para geração de fluxogramas PRISMA 2020.

## 🚀 Deploy no Railway

1. Faça upload destes arquivos para um repositório GitHub
2. No Railway: **New Project → Deploy from GitHub**
3. Aguarde o build (~1-2 minutos)
4. Em **Settings → Networking → Generate Domain**
5. Teste: `https://seu-dominio.up.railway.app/health`

## 📡 Endpoints

### `GET /health`
Verifica se a API está online.

### `GET /`
Retorna documentação e exemplo de payload.

### `GET /docs`
Documentação interativa Swagger.

### `POST /generate-prisma-simple`
Gera fluxograma PRISMA 2020.

**Payload:**
```json
{
  "identified": 450,
  "duplicates": 70,
  "screened": 380,
  "excluded_screening": 300,
  "sought_retrieval": 80,
  "not_retrieved": 5,
  "assessed_eligibility": 75,
  "excluded_fulltext": 45,
  "exclusion_reasons": {
    "Sem desfecho primário": 20,
    "População inadequada": 15,
    "Desenho inadequado": 10
  },
  "included_studies": 30
}
```

**Resposta:**
```json
{
  "success": true,
  "base64": "iVBORw0KGgo...",
  "format": "png",
  "message": "Fluxograma PRISMA gerado com sucesso"
}
```

## 🐍 Exemplo Python

```python
import requests
import base64

url = "https://seu-dominio.up.railway.app/generate-prisma-simple"

payload = {
    "identified": 450,
    "duplicates": 70,
    "screened": 380,
    "excluded_screening": 300,
    "sought_retrieval": 80,
    "not_retrieved": 5,
    "assessed_eligibility": 75,
    "excluded_fulltext": 45,
    "included_studies": 30
}

response = requests.post(url, json=payload)
data = response.json()

if data["success"]:
    with open("prisma.png", "wb") as f:
        f.write(base64.b64decode(data["base64"]))
    print("Salvo: prisma.png")
```

## 🤖 Exemplo n8n

```json
{
  "method": "POST",
  "url": "https://seu-dominio.up.railway.app/generate-prisma-simple",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "identified": "={{ $json.identified }}",
    "duplicates": "={{ $json.duplicates }}",
    "screened": "={{ $json.screened }}",
    "excluded_screening": "={{ $json.excluded }}",
    "sought_retrieval": "={{ $json.full_text }}",
    "assessed_eligibility": "={{ $json.full_text }}",
    "excluded_fulltext": "={{ $json.excluded_fulltext }}",
    "included_studies": "={{ $json.studies_included }}"
  }
}
```

## 📁 Estrutura

```
├── Dockerfile      # Imagem Python + Graphviz
├── main.py         # API FastAPI
├── example.json    # Payload de exemplo
└── README.md
```

## 🔧 Rodar localmente

```bash
# Com Docker
docker build -t prisma-api .
docker run -p 8000:8000 prisma-api

# Sem Docker
pip install fastapi uvicorn graphviz pillow python-multipart
uvicorn main:app --reload
```

## 📝 Licença

MIT

---

**Autor:** Dr. Vitor Alves Felippe
