# Usa imagem base com R e shiny já configurados
FROM rocker/shiny:4.3.2

# Instala dependências do sistema para PRISMA2020
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    librsvg2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala pacotes R necessários
RUN R -e "install.packages(c('plumber', 'jsonlite', 'base64enc'), repos='https://cloud.r-project.org', Ncpus=4)"

# Instala PRISMA2020 e dependências
RUN R -e "install.packages('PRISMA2020', repos='https://cloud.r-project.org', Ncpus=4)"

# Verifica
RUN R -e "library(plumber); library(PRISMA2020); cat('OK\n')"

WORKDIR /app
COPY api.R /app/api.R

ENV PORT=8000
EXPOSE ${PORT}

CMD ["sh", "-c", "R -e \"library(plumber); pr <- plumb('api.R'); pr\\$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8000)))\""]
