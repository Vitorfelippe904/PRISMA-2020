# 📊 PRISMA-2020 API  
API em R (Plumber) para geração automatizada de fluxogramas PRISMA 2020 a partir de dados estruturados.  
Ideal para pipelines de Revisões Sistemáticas, Meta-Análises, RAG científico e automações no n8n.

---

## 🚀 1. Objetivo

Esta API recebe um JSON contendo os números do fluxograma PRISMA (identificação, triagem, elegibilidade e inclusão) e gera:

- 📄 **Fluxograma PRISMA completo** (PNG ou PDF)  
- 🔢 **Tabela PRISMA estruturada**  
- 🧬 **Retorno em Base64** (compatível com n8n, Supabase, WhatsApp bots, Assistants e pipelines automatizados)

A API é deployada via **Docker + Railway**.

---

## 📦 2. Estrutura do Repositório
├── Dockerfile          # Define a imagem e o ambiente
├── api.R               # Rotas da API (Plumber)
├── prisma_cli.R        # Lógica de gerar o fluxograma PRISMA
├── example.json        # Exemplo de payload
└── README.md           # Este arquivo
---

## 🛠️ 3. Requisitos

### Local
- R ≥ 4.2
- Pacotes: `plumber`, `jsonlite`, `PRISMA2020`, `base64enc`
- Docker (opcional para rodar local via container)

### Produção (Railway)
O Dockerfile já define:
- Instalação dos pacotes R  
- Exposição da porta `8000`  
- Execução da API em `/usr/local/bin/R -f api.R`  

---

## ⚙️ 4. Como rodar LOCALMENTE

### 4.1 Sem Docker

```bash
Rscript api.R
A API iniciará em:
[A API iniciará em:](http://localhost:8000)

4.2 Com Docker
docker build -t prisma-api .
docker run -p 8000:8000 prisma-api

🌐 5. Deploy no Railway
	1.	Suba TODOS os arquivos no GitHub
	2.	No Railway, escolha “Deploy from GitHub repo”
	3.	Railway detectará o Dockerfile automaticamente
	4.	Gere um domínio público em:
Settings → Networking → Generate Domain
	5.	Verifique em /health

🧪 6. Endpoints

🔍 GET /health

Verifica se a API está online.
{ "status": "ok" }
🟦 POST /generate-prisma

Gera o fluxograma PRISMA 2020.

Payload JSON
{
  "identified": 450,
  "after_duplicates": 380,
  "screened": 380,
  "excluded": 300,
  "full_text": 80,
  "excluded_fulltext": 50,
  "studies_included": 30
}
{
  "identified": 450,
  "after_duplicates": 380,
  "screened": 380,
  "excluded": 300,
  "full_text": 80,
  "excluded_fulltext": 50,
  "studies_included": 30
}
Resposta
{
  "base64": "<string>",
  "format": "png",
  "success": true
}
🧪 7. Exemplo em CURL
curl -X POST YOUR-RAILWAY-URL/generate-prisma \
-H "Content-Type: application/json" \
-d @example.json

🐍 8. Exemplo em Python
import requests

url = "https://prisma-2020-production.up.railway.app/generate-prisma"

payload = {
    "identified": 450,
    "after_duplicates": 380,
    "screened": 380,
    "excluded": 300,
    "full_text": 80,
    "excluded_fulltext": 50,
    "studies_included": 30
}

r = requests.post(url, json=payload)
img_b64 = r.json()["base64"]

# salva o PNG
import base64
with open("prisma.png", "wb") as f:
    f.write(base64.b64decode(img_b64))
🤖 9. Uso no n8n (exemplo JSON)
{
  "url": "https://prisma-2020-production.up.railway.app/generate-prisma",
  "method": "POST",
  "json": {
    "identified": {{$json.identified}},
    "after_duplicates": {{$json.after_duplicates}},
    "screened": {{$json.screened}},
    "excluded": {{$json.excluded}},
    "full_text": {{$json.full_text}},
    "excluded_fulltext": {{$json.excluded_fulltext}},
    "studies_included": {{$json.studies_included}}
  }
}
🙋‍♂️ 12. Autor

Dr. Vitor Alves Felippe
Automação científica | IA aplicada | Meta-análises automatizadas | Anestesia & Pesquisa
---

# ✅ Pronto para subir no GitHub

Se quiser, posso também:

✔ Gerar **badges** (build, version, uptime, Docker pulls)  
✔ Criar **example.json completo**  
✔ Criar **README em inglês**  
✔ Criar **versão com pkgdown**  
✔ Criar **versão para publicar como pacote CRAN no futuro**  

Só pedir!
