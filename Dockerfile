FROM rocker/r-ver:4.3.2

# Instala dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala pacotes R
RUN R -e "install.packages('jsonlite', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('base64enc', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org', dependencies=TRUE)"

# Verifica instalação
RUN R -e "library(plumber); cat('Plumber OK\n')"

WORKDIR /app
COPY api.R /app/api.R

ENV PORT=8000
EXPOSE ${PORT}

CMD ["sh", "-c", "R -e \"library(plumber); pr <- plumb('api.R'); pr\\$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8000)))\""]
