FROM rocker/r-ver:4.3.2

# Dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    librsvg2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala plumber e verifica
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org', dependencies=TRUE)" && \
    R -e "if (!require('plumber')) stop('plumber falhou')"

# Instala jsonlite e base64enc
RUN R -e "install.packages(c('jsonlite', 'base64enc'), repos='https://cloud.r-project.org')" && \
    R -e "if (!require('jsonlite')) stop('jsonlite falhou')" && \
    R -e "if (!require('base64enc')) stop('base64enc falhou')"

# Instala PRISMA2020 e dependências
RUN R -e "install.packages('PRISMA2020', repos='https://cloud.r-project.org', dependencies=TRUE)" && \
    R -e "if (!require('PRISMA2020')) stop('PRISMA2020 falhou')"

# Verificação final
RUN R -e "library(plumber); library(PRISMA2020); library(jsonlite); library(base64enc); cat('TODOS OS PACOTES OK\n')"

WORKDIR /app
COPY api.R /app/api.R

ENV PORT=8000
EXPOSE ${PORT}

CMD ["sh", "-c", "R -e \"library(plumber); pr <- plumb('api.R'); pr\\$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8000)))\""]
