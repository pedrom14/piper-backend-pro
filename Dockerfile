FROM python:3.10-bullseye

RUN apt-get update && apt-get install -y \
    curl unzip sox espeak-ng-data libespeak-ng1 \
    && apt-get clean

WORKDIR /app

COPY . .

RUN chmod +x piper

RUN pip install -r requirements.txt

CMD ["python", "app.py"]

