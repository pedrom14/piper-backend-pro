FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Instalar apenas o essencial (não precisamos mais do espeak-ng)
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    libatomic1 \
    libgomp1 \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho
WORKDIR /app

# Clonar o código-fonte do Piper
RUN git clone https://github.com/rhasspy/piper.git

# Compilar o Piper sem o espeak-ng (aqui está o detalhe crítico!)
WORKDIR /app/piper
RUN cmake -DWITH_ESPEAK=OFF -B build && cmake --build build -j $(nproc)

# Voltar ao diretório principal
WORKDIR /app

# Copiar as dependências Python
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o restante do seu projeto
COPY . .

# Copiar o binário compilado para a raiz do app
RUN cp /app/piper/build/piper /app/piper
RUN chmod +x /app/piper/piper

# Expor a porta
EXPOSE 5000

# Comando de inicialização
CMD ["python", "app.py"]
