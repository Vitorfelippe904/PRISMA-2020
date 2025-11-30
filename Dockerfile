FROM python:3.11-slim

# Instala Graphviz
RUN apt-get update && apt-get install -y --no-install-recommends \
    graphviz \
    fonts-liberation \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala dependências Python
RUN pip install --no-cache-dir \
    fastapi \
    uvicorn \
    graphviz \
    pillow \
    python-multipart

WORKDIR /app
COPY main.py /app/main.py

ENV PORT=8000
EXPOSE ${PORT}

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT}"]
