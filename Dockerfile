# Etapa 1: Compilar o Piper
FROM debian:bookworm AS builder

WORKDIR /build

# Instala dependências para compilar o Piper
RUN apt-get update && apt-get install -y \
  git \
  cmake \
  g++ \
  python3 \
  python3-pip \
  curl \
  unzip \
  sox \
  espeak-ng \
  espeak-ng-data \
  libespeak-ng1 \
  libsndfile1-dev \
  libx11-dev \
  libx11-xcb-dev \
  libpulse-dev \
  libpcaudio-dev \
  && rm -rf /var/lib/apt/lists/*

# Clona o Piper
RUN git clone https://github.com/rhasspy/piper.git

# Compila o Piper
WORKDIR /build/piper
RUN cmake -B build && cmake --build build -j$(nproc)

# Etapa 2: Container final
FROM python:3.10-slim

WORKDIR /app

# Instala bibliotecas necessárias para rodar o Piper
RUN apt-get update && apt-get install -y \
  sox \
  espeak-ng-data \
  libespeak-ng1 \
  libsndfile1 \
  libx11-6 \
  libx11-xcb1 \
  libpulse0 \
  libpcaudio0 \
  libcurl4 \
  && ln -s /usr/lib/x86_64-linux-gnu/libespeak-ng.so.1 /usr/local/lib/libespeak-ng.so.1 \
  && rm -rf /var/lib/apt/lists/*

# Instala dependências Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o app
COPY app.py .

# Copia binário do Piper e libs necessárias
COPY --from=builder /build/piper/build/piper /app/piper
COPY --from=builder /build/piper/build/libpiper_phonemize.so* /usr/local/lib/
COPY --from=builder /usr/lib/libonnxruntime.so.* /usr/local/lib/
RUN chmod +x /app/piper && ldconfig


# Copia os arquivos de voz
COPY pt_BR-edresson-low.onnx .
COPY pt_BR-edresson-low.onnx.json .

# Permissões de execução
RUN chmod +x /app/piper && ldconfig

EXPOSE 5000
CMD ["python", "app.py"]



