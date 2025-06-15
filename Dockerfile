FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng-data \
    libespeak-ng-dev \
    libatomic1 \
    libgomp1 \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/piper-tts/piper.git && \
    cd piper && \
    cmake -B build && cmake --build build -j $(nproc) && \
    cp build/piper /app/piper && \
    chmod +x /app/piper && \
    rm -rf piper

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
