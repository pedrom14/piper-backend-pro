from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import subprocess
import os
import uuid

app = Flask(__name__)
CORS(app)

VOICE_PATH = "models/ptBR/pt_BR-edresson-low.onnx"
CONFIG_PATH = "models/ptBR/pt_BR-edresson-low.onnx.json"

@app.route("/tts", methods=["POST"])
def tts():
    data = request.get_json()
    text = data.get("text")

    if not text:
        return jsonify({"error": "Texto não fornecido."}), 400

    output_path = f"output_{uuid.uuid4().hex}.wav"

    try:
        subprocess.run([
            "./piper", "--model", VOICE_PATH, "--config", CONFIG_PATH,
            "--output_file", output_path, "--text", text
        ], check=True)

        return send_file(output_path, mimetype="audio/wav")

    except subprocess.CalledProcessError:
        return jsonify({"error": "Erro ao gerar o áudio."}), 500
    finally:
        if os.path.exists(output_path):
            os.remove(output_path)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)