FROM python:3.9-slim-bullseye

WORKDIR /app


RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV SERIAL_PORT=/dev/ttyACM0
ENV BAUD_RATE=9600
ENV USE_MOCK=False

# 컨테이너 실행 시 작동할 명령어
CMD ["python", "main.py"]