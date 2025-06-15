FROM python:3.10-bullseye

ENV DEBIAN_FRONTEND=noninteractive

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

WORKDIR /app

RUN git clone https://github.com/rhasspy/piper.git

WORKDIR /app/piper
RUN cmake -B build -DWITH_ESPEAK=OFF && cmake --build build -j $(nproc)

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN cp /app/piper/build/piper /app/piper
RUN chmod +x /app/piper/piper

EXPOSE 5000

CMD ["python", "app.py"]
