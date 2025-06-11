FROM ubuntu:22.04

RUN apt update && apt install -y python3 python3-pip curl

WORKDIR /app
COPY . .

RUN pip3 install -r requirements.txt
RUN chmod +x piper

EXPOSE 5000

CMD ["python3", "app.py"]
