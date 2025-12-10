# 기본 이미지: Debian Bookworm 기반 Python 3.11 슬림 버전
FROM python:3.11-slim-bookworm

# 작업 디렉토리 설정
WORKDIR /workspace

# 환경 변수 설정
ENV DEBIAN_FRONTEND=noninteractive

# 1. GStreamer 런타임 및 필수 플러그인 설치 (최소화된 목록)
# libglib2.0-0는 GStreamer와 많은 시스템 라이브러리의 기본 의존성이므로 유지합니다.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # GStreamer 런타임 및 플러그인
        libgstreamer1.0-0 \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-libav \
        # GStreamer의 핵심 의존성 (GUI와 무관)
        libglib2.0-0 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# 2. requirements.txt 복사 및 Python 종속성 설치
# requirements.txt에 opencv-python-headless가 포함되어 있어야 합니다.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. 애플리케이션 파일 복사
COPY . .

CMD ["python", "script/main.py"]