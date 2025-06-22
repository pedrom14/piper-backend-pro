from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import subprocess
import uuid
import os

app = Flask(__name__)
CORS(app)

@app.route("/tts", methods=["POST"])
def tts():
    data = request.get_json()
    text = data.get("text", "")
    voice = "pt_BR-edresson-low"
    
    if not text:
        return jsonify({"error": "Texto vazio"}), 400

    output_wav = f"{uuid.uuid4()}.wav"
    command = [
        "./piper",
        "--model", f"models/{voice}.onnx",
        "--config", f"models/{voice}.onnx.json",
        "--output_file", output_wav,
        "--sentence_silence", "0.5",
        "--phoneme_silence", "0.1",
        "--length_scale", "1.0",
        "--noise_scale", "0.667",
        "--noise_w", "0.8",
        "--text", text
    ]

    try:
        subprocess.run(command, check=True)
        return send_file(output_wav, mimetype="audio/wav")
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        if os.path.exists(output_wav):
            os.remove(output_wav)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)



