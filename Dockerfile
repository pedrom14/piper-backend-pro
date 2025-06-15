FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências de sistema para o Piper e suas bibliotecas nativas
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng-data \
    libespeak-ng-dev \
    libatomic1 \
    libgomp1 \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho
WORKDIR /app

# Baixar binário pré-compilado do Piper
RUN curl -L -o piper.tar.gz https://github.com/rhasspy/piper/releases/download/v1.2.0/piper_linux_x86_64.tar.gz && \
    tar -xzf piper.tar.gz && \
    mv piper /app/piper && \
    chmod +x /app/piper && \
    rm -rf piper.tar.gz

# Copiar requirements e instalar dependências Python
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar restante do projeto
COPY . .

# Expor porta
EXPOSE 5000

# Comando de inicialização
CMD ["python", "app.py"]


