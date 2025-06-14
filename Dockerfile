FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências de sistema para build do Piper
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng-data \
    build-essential \
    cmake \
    git \
    libespeak-ng-dev \
    libatomic1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Definir diretório de trabalho
WORKDIR /app

# Clonar o código-fonte do Piper
RUN git clone https://github.com/rhasspy/piper.git

# Compilar o Piper (versão release)
WORKDIR /app/piper
RUN cmake -B build && cmake --build build -j $(nproc)

# Voltar ao diretório do app
WORKDIR /app

# Copiar dependências Python
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o restante do projeto
COPY . .

# Copiar o binário compilado para a raiz do app
RUN cp /app/piper/build/piper /app/piper

# Dar permissão de execução
RUN chmod +x /app/piper

# Expõe a porta
EXPOSE 5000

# Comando de inicialização
CMD ["python", "app.py"]


