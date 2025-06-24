from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import subprocess
import uuid
import os

app = Flask(__name__)
CORS(app)

@app.route('/tts', methods=['POST'])
def tts():
    data = request.get_json(silent=True) or {}
    texto = data.get('text', '')
    voice = 'pt_BR-edresson-low'

    if not texto:
        return jsonify({'error': 'Texto não fornecido'}), 400

    output_filename = f'output_{uuid.uuid4().hex}.wav'

    command = [
        './piper',
        '--model', f'{voice}.onnx',
        '--config', f'{voice}.onnx.json',
        '--output_file', output_filename,
        '--text', texto
    ]

    try:
        subprocess.run(command, check=True)
        return send_file(output_filename, mimetype='audio/wav')
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        if os.path.exists(output_filename):
            os.remove(output_filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)




