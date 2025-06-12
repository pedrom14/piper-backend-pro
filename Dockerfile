FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng-data \
    && rm -rf /var/lib/apt/lists/*

# Baixar o binário do Piper
RUN curl -L https://github.com/rhasspy/piper/releases/latest/download/piper_linux_x86_64.tar.gz -o piper.tar.gz && \
    tar -xzf piper.tar.gz && \
    rm piper.tar.gz

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x /app/piper

CMD ["python", "app.py"]