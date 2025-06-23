# Imagem base
FROM python:3.10-slim

# Diretório de trabalho
WORKDIR /app

# Instala dependências do sistema, incluindo a biblioteca espeak-ng necessária
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sox \
    espeak-ng-data \
    libespeak-ng1 \
    && rm -rf /var/lib/apt/lists/*

# Copia os arquivos do backend
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY piper .                          
COPY pt_BR-edresson-low.onnx .
COPY pt_BR-edresson-low.onnx.json .

# Garante que o executável do Piper tenha permissão de execução
RUN chmod +x /app/piper

# Expõe a porta usada pelo Flask
EXPOSE 5000

# Comando padrão
CMD ["python", "app.py"]

