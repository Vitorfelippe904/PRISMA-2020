
FROM rocker/r-ver:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('plumber','remotes'), repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_github('prisma-flowdiagram/PRISMA2020')"

# Copy service files
WORKDIR /app
COPY api.R /app/api.R

EXPOSE 8000

CMD ["Rscript", "api.R"]
