import os
import json
import requests
import numpy as np
import onnxruntime as ort
import scipy.io.wavfile
from flask import Flask, request, send_file, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Links dos seus arquivos no Cloudflare R2
ONNX_URL = "https://pub-ce3bb4b09b4347da9e4835d744965af1.r2.dev/pt_BR-edresson-low.onnx"
JSON_URL = "https://pub-ce3bb4b09b4347da9e4835d744965af1.r2.dev/pt_BR-edresson-low.onnx.json"

MODEL_DIR = "models/ptBR"
MODEL_PATH = os.path.join(MODEL_DIR, "pt_BR-edresson-low.onnx")
CONFIG_PATH = os.path.join(MODEL_DIR, "pt_BR-edresson-low.onnx.json")

# Função para baixar os modelos se ainda não existirem
def download_models():
    os.makedirs(MODEL_DIR, exist_ok=True)

    if not os.path.exists(MODEL_PATH):
        print("Baixando modelo ONNX...")
        r = requests.get(ONNX_URL)
        with open(MODEL_PATH, 'wb') as f:
            f.write(r.content)

    if not os.path.exists(CONFIG_PATH):
        print("Baixando config JSON...")
        r = requests.get(JSON_URL)
        with open(CONFIG_PATH, 'wb') as f:
            f.write(r.content)

# Função principal de geração TTS com ONNX
def synthesize_speech(text):
    session = ort.InferenceSession(MODEL_PATH)
    
    with open(CONFIG_PATH, 'r') as f:
        config = json.load(f)

    sample_rate = config.get("sample_rate", 22050)

    # Atenção: aqui neste ponto o processamento completo de texto -> ids fonêmicos normalmente seria feito.
    # Como o pipeline completo envolve tokenizer + phonemizer + normalização (coisa que o Piper CLI faz), 
    # nesse backend simplificado ainda não temos o pré-processamento completo, 
    # portanto aqui simulamos só para fins de teste.

    # Vamos gerar um áudio vazio novamente para simular a estrutura completa rodando:
    duration_seconds = 2
    audio = np.zeros(int(sample_rate * duration_seconds), dtype=np.int16)
    scipy.io.wavfile.write("output.wav", sample_rate, audio)

    # ⚠ IMPORTANTE: 
    # Na próxima etapa podemos plugar o pipeline completo do Piper para gerar a voz real aqui.

@app.route('/tts', methods=['POST'])
def tts():
    data = request.get_json()

    if not data or 'text' not in data:
        return jsonify({'error': 'Parâmetro \"text\" obrigatório'}), 400

    text = data['text']

    download_models()
    synthesize_speech(text)

    return send_file("output.wav", mimetype='audio/wav')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

