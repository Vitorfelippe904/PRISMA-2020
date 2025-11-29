# 📊 PRISMA-2020 API

API em R (Plumber) para geração automatizada de fluxogramas PRISMA 2020 oficiais.

## 🚀 Deploy no Railway

1. Faça fork/clone deste repositório
2. No Railway: **New Project → Deploy from GitHub**
3. Aguarde o build (pode levar ~5-10 min na primeira vez)
4. Em **Settings → Networking → Generate Domain**
5. Teste: `https://seu-dominio.up.railway.app/health`

## 📡 Endpoints

### `GET /health`
Verifica se a API está online.

```bash
curl https://seu-dominio.up.railway.app/health
```

Resposta:
```json
{"status": "ok", "timestamp": "2025-01-01 12:00:00"}
```

### `POST /generate-prisma-simple`
Versão simplificada - ideal para a maioria dos casos.

**Payload:**
```json
{
  "identified": 450,
  "after_duplicates": 380,
  "screened": 380,
  "excluded": 300,
  "full_text": 80,
  "excluded_fulltext": 50,
  "studies_included": 30,
  "format": "png"
}
```

**Exemplo curl:**
```bash
curl -X POST https://seu-dominio.up.railway.app/generate-prisma-simple \
  -H "Content-Type: application/json" \
  -d @example.json
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

### `POST /generate-prisma`
Versão completa com todos os campos PRISMA 2020.

**Payload:**
```json
{
  "identified": 500,
  "duplicates": 50,
  "screened": 450,
  "excluded_screening": 350,
  "sought_retrieval": 100,
  "not_retrieved": 5,
  "assessed_eligibility": 95,
  "excluded_reasons": {"Sem desfecho": 30, "População errada": 15, "Sem comparador": 10},
  "included_studies": 40,
  "included_reports": 45,
  "format": "png"
}
```

## 🐍 Exemplo Python

```python
import requests
import base64

url = "https://seu-dominio.up.railway.app/generate-prisma-simple"

payload = {
    "identified": 450,
    "after_duplicates": 380,
    "screened": 380,
    "excluded": 300,
    "full_text": 80,
    "excluded_fulltext": 50,
    "studies_included": 30,
    "format": "png"
}

response = requests.post(url, json=payload)
data = response.json()

if data["success"]:
    with open("prisma.png", "wb") as f:
        f.write(base64.b64decode(data["base64"]))
    print("Salvo: prisma.png")
else:
    print(f"Erro: {data['error']}")
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
    "after_duplicates": "={{ $json.after_duplicates }}",
    "screened": "={{ $json.screened }}",
    "excluded": "={{ $json.excluded }}",
    "full_text": "={{ $json.full_text }}",
    "excluded_fulltext": "={{ $json.excluded_fulltext }}",
    "studies_included": "={{ $json.studies_included }}",
    "format": "png"
  }
}
```

## 📁 Estrutura

```
├── Dockerfile      # Imagem Docker com R + PRISMA2020
├── api.R           # API Plumber
├── example.json    # Payload de exemplo
└── README.md
```

## 🔧 Rodar localmente

```bash
# Com Docker
docker build -t prisma-api .
docker run -p 8000:8000 prisma-api

# Sem Docker (requer R instalado)
Rscript -e "plumber::plumb('api.R')\$run(host='0.0.0.0', port=8000)"
```

## 📝 Licença

MIT

---

**Autor:** Dr. Vitor Alves Felippe
