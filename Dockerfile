FROM python:3.10-slim

WORKDIR /appdir

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .
COPY piper .           # <- Executável compilado
COPY pt_BR-edresson-low.onnx .
COPY pt_BR-edresson-low.onnx.json .

RUN chmod +x /app/piper

CMD ["python", "app.py"]

