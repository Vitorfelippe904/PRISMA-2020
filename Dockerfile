FROM rocker/r-ver:4.3.2

# Dependências do sistema para PRISMA2020 (gráficos + webshot)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libcairo2-dev \
    libxt-dev \
    libv8-dev \
    pandoc \
    chromium-browser \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configura chromium para webshot2
ENV CHROMOTE_CHROME=/usr/bin/chromium-browser

# Instala pacotes R
RUN R -e "install.packages('jsonlite', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('base64enc', repos='https://cloud.r-project.org')"
RUN R -e "install.packages('plumber', repos='https://cloud.r-project.org', dependencies=TRUE)"
RUN R -e "install.packages('webshot2', repos='https://cloud.r-project.org', dependencies=TRUE)"
RUN R -e "install.packages('PRISMA2020', repos='https://cloud.r-project.org', dependencies=TRUE)"

# Verifica instalação
RUN R -e "library(plumber); library(PRISMA2020); library(webshot2); cat('OK\n')"

WORKDIR /app
COPY api.R /app/api.R

ENV PORT=8000
EXPOSE ${PORT}

CMD ["sh", "-c", "R -e \"library(plumber); pr <- plumb('api.R'); pr\\$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT', 8000)))\""]
