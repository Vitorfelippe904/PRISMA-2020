FROM rocker/r-base:4.3.1

# Instala dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    make \
    gcc \
    g++ \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala pacotes R com verificação de erro
RUN R -e "install.packages(c('plumber', 'jsonlite', 'base64enc'), repos='https://cloud.r-project.org', dependencies=TRUE)" \
    && R -e "if (!requireNamespace('plumber', quietly=TRUE)) quit(status=1)"

# Cria diretório de trabalho
WORKDIR /app

# Copia os arquivos da API
COPY api.R /app/api.R

# Railway usa variável PORT
ENV PORT=8000

EXPOSE ${PORT}

# Comando de inicialização
CMD R -e "library(plumber); pr <- plumb('api.R'); pr\$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8000)))"
