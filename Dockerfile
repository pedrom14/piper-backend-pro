FROM python:3.10-bullseye

# Variável para deixar o ambiente não interativo
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza o sistema e instala dependências nativas que o Piper precisa
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng-data \
    libgomp1 \
    libatomic1 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Cria diretório de trabalho
WORKDIR /app

# Baixa e extrai o Piper diretamente dentro do /app
RUN curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz -o piper.tar.gz && \
    tar -xzf piper.tar.gz && \
    rm piper.tar.gz

# Permissão de execução do binário piper
RUN chmod +x /app/piper

# Copia e instala os requisitos python
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copia os arquivos restantes
COPY . .

# Porta padrão do app Flask
EXPOSE 5000

# Comando para iniciar o servidor
CMD ["python", "app.py"]



