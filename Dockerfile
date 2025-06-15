FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng \
    espeak-ng-data \
    libespeak-ng-dev \
    libatomic1 \
    libgomp1 \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Agora clonar o espeak-ng completo
RUN git clone https://github.com/espeak-ng/espeak-ng.git /tmp/espeak-ng

# Copiar o diretório espeak-ng-data completo
RUN cp -r /tmp/espeak-ng/espeak-ng-data /usr/share/espeak-ng-data

WORKDIR /app

RUN git clone https://github.com/rhasspy/piper.git

WORKDIR /app/piper
RUN cmake -B build && cmake --build build -j $(nproc)

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN cp /app/piper/build/piper /app/piper
RUN chmod +x /app/piper/piper

EXPOSE 5000

CMD ["python", "app.py"]



