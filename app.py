import os
import requests
import numpy as np
import onnxruntime as ort
import json
from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import scipy.io.wavfile

app = Flask(__name__)
CORS(app)

# URLs dos arquivos
ONNX_URL = "https://pub-ce3bb4b09b4347da9e4835d744965af1.r2.dev/pt_BR-edresson-low.onnx"
JSON_URL = "https://pub-ce3bb4b09b4347da9e4835d744965af1.r2.dev/pt_BR-edresson-low.onnx.json"

MODEL_DIR = "models/ptBR"
MODEL_PATH = os.path.join(MODEL_DIR, "pt_BR-edresson-low.onnx")
CONFIG_PATH = os.path.join(MODEL_DIR, "pt_BR-edresson-low.onnx.json")

# Baixar modelos caso ainda não existam
def download_models():
    os.makedirs(MODEL_DIR, exist_ok=True)

    if not os.path.exists(MODEL_PATH):
        r = requests.get(ONNX_URL)
        with open(MODEL_PATH, 'wb') as f:
            f.write(r.content)

    if not os.path.exists(CONFIG_PATH):
        r = requests.get(JSON_URL)
        with open(CONFIG_PATH, 'wb') as f:
            f.write(r.content)

# Carregar modelo
def load_model():
    session = ort.InferenceSession(MODEL_PATH)
    with open(CONFIG_PATH, 'r') as f:
        config = json.load(f)
    return session, config

# Simulação simplificada só para fechar o pipeline (não faz TTS real ainda)
def generate_audio(text, session, config):
    # Aqui normalmente entra o pré-processamento (tokenizer, phonemizer, etc.)
    # Como exemplo simplificado, só criaremos um arquivo WAV de silêncio (para validar backend)
    sr = config.get("sample_rate", 22050)
    audio = np.zeros(int(sr * 2), dtype=np.int16)  # 2 segundos de silêncio
    scipy.io.wavfile.write("output.wav", sr, audio)

@app.route('/tts', methods=['POST'])
def tts():
    data = request.get_json()

    if not data or 'text' not in data:
        return jsonify({'error': 'Parâmetro \"text\" obrigatório'}), 400

    text = data['text']

    download_models()
    session, config = load_model()
    generate_audio(text, session, config)

    return send_file("output.wav", mimetype='audio/wav')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
