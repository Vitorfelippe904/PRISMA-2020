FROM rocker/r-ver:4.3.1

# Instala os pacotes necessários em R
RUN R -e "install.packages(c('plumber','jsonlite','base64enc','PRISMA2020'), repos='https://cloud.r-project.org')"

WORKDIR /app

# Copia os scripts da API
COPY api.R prisma_cli.R ./

# Expõe a porta que o plumber vai usar
EXPOSE 8000

# Comando de inicialização da API
CMD ["R", "-e", "pr <- plumber::plumb('api.R'); pr$run(host='0.0.0.0', port=8000)"]
