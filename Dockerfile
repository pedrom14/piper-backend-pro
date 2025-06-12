FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng-data \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz -o piper.tar.gz && \
    tar -xzf piper.tar.gz && \
    rm piper.tar.gz

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN curl -L "https://drive.google.com/uc?export=download&id=1z1ada2pbxBEA3TrS54W0vSNfHLJrOC7e" -o models/ptBR/pt_BR-edresson-low.onnx && \
    curl -L "https://drive.google.com/uc?export=download&id=1AYGd57M27cx25rGpQx8JqO2r9dkc1XEe" -o models/ptBR/pt_BR-edresson-low.onnx.json

RUN chmod +x /app/piper

CMD ["python", "app.py"]