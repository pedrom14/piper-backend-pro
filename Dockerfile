FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências mínimas
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    libatomic1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Baixar binário oficial do Piper (com URL corrigida!)
RUN curl -L -o piper.tar.gz https://github.com/rhasspy/piper/releases/download/v1.2.0/piper-linux-x86_64.tar.gz \
    && tar -xzf piper.tar.gz \
    && mv piper /app/piper \
    && chmod +x /app/piper \
    && rm -rf piper.tar.gz

# Copiar dependências Python
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar seu código
COPY . .

EXPOSE 5000

CMD ["python", "app.py"]

