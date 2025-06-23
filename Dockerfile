# Imagem base
FROM python:3.10-slim

# Diretório de trabalho
WORKDIR /app

# Instala bibliotecas do sistema necessárias
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng-data \
    libespeak-ng1 \
    libcurl4 \
    libx11-6 \
    libx11-xcb1 \
    libpulse0 \
    libpcaudio0 \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Copia os requisitos do Python e instala
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o app principal
COPY app.py .

# Copia os arquivos essenciais do Piper
COPY piper .
COPY libpiper_phonemize.so.1 /usr/local/lib/
COPY libonnxruntime.so.1.14.1 /usr/local/lib/
RUN ldconfig

# Copia o modelo de voz
COPY pt_BR-edresson-low.onnx .
COPY pt_BR-edresson-low.onnx.json .

# Garante permissão de execução do binário
RUN chmod +x /app/piper

# Expõe a porta usada pelo Flask
EXPOSE 5000

# Comando para rodar o backend
CMD ["python", "app.py"]

