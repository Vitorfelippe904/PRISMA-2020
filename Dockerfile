FROM rocker/r-ver:4.3.1

# Instala dependências do sistema necessárias para o plumber e PRISMA2020
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Instala os pacotes R
RUN R -e "install.packages( \
    c('plumber', 'jsonlite', 'base64enc', 'PRISMA2020'), \
    repos = 'https://cloud.r-project.org' \
)"

# Define a pasta do app
WORKDIR /app

# Copia os arquivos da API
COPY api.R prisma_cli.R ./

# Expõe a porta
EXPOSE 8000

# Comando para iniciar a API
CMD ["R", "-e", "pr <- plumber::plumb('api.R'); pr$run(host='0.0.0.0', port=8000)"]
