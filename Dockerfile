FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY models/ptBR/.gitkeep models/ptBR/.gitkeep

# Baixando os arquivos de modelo diretamente no build
RUN curl -L "https://drive.google.com/uc?export=download&id=1z1ada2pbxBEA3TrS54W0vSNfHLJrOC7e" -o models/ptBR/pt_BR-edresson-low.onnx && \
    curl -L "https://drive.google.com/uc?export=download&id=1AYGd57M27cx25rGpQx8JqO2r9dkc1XEe" -o models/ptBR/pt_BR-edresson-low.onnx.json

CMD ["python", "app.py"]
