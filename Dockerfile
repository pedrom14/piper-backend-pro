FROM python:3.10-slim

# Atualiza e instala dependências necessárias
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng-data \
    && rm -rf /var/lib/apt/lists/*

# Cria diretório de trabalho
WORKDIR /app

# Baixa e extrai o Piper diretamente no diretório correto
RUN curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz -o piper.tar.gz && \
    tar -xzf piper.tar.gz && \
    rm piper.tar.gz

# Torna o binário executável
RUN chmod +x /app/piper

# Instala as dependências Python
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copia o restante dos arquivos
COPY . .

CMD ["python", "app.py"]



