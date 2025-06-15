# Stage 1: Compilar o Piper
FROM python:3.10-bullseye AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    libespeak-ng-dev \
    libatomic1 \
    libgomp1 \
    curl \
    unzip \
    sox \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clonar o Piper
RUN git clone https://github.com/rhasspy/piper.git

WORKDIR /app/piper

# Compilar o Piper com suporte a ONNX, sem AVX (compatível com qualquer CPU)
RUN cmake -DWITH_ESPEAK=OFF -B build && cmake --build build -j $(nproc)

# Stage 2: Montar a imagem final leve
FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libatomic1 \
    libgomp1 \
    sox \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar o binário compilado do Piper
COPY --from=builder /app/piper/build/piper /app/piper
RUN chmod +x /app/piper

# Copiar dependências Python
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o restante do código
COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
