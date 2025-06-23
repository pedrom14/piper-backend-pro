FROM python:3.10-slim

WORKDIR /code

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .
COPY piper .
COPY pt_BR-edresson-low.onnx .
COPY pt_BR-edresson-low.onnx.json .

RUN chmod +x piper

CMD ["python", "app.py"]

