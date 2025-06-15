# Stage 1: Build do Piper (multi-stage)
FROM python:3.10-bullseye as builder

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

RUN git clone https://github.com/rhasspy/piper.git

WORKDIR /app/piper

# Compilando o Piper com espeak-ng desativado (leve, para Fly.io)
RUN cmake -DWITH_ESPEAK=OFF -B build && cmake --build build -j $(nproc)

# Stage 2: Imagem final leve
FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libatomic1 \
    libgomp1 \
    sox \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/piper/build/piper /app/piper
RUN chmod +x /app/piper

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]

