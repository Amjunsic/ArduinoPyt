# 1. 베이스 이미지: 라즈베리 파이 OS와 동일한 Debian 12 (Bookworm) Slim
# ARM64 아키텍처를 자동으로 감지하여 적절한 이미지를 가져옵니다.
FROM debian:bookworm-slim

# 작업 디렉토리 설정
WORKDIR /workspace

# 환경 변수 설정
# - DEBIAN_FRONTEND: 설치 중 사용자 입력 대기 방지
# - PYTHONUNBUFFERED: 로그가 즉시 출력되도록 설정 (디버깅 용이)
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

# 2. 시스템 패키지 설치
# - python3-opencv: GStreamer가 포함된 미리 빌드된 OpenCV
# - gstreamer1.0-*: 각종 플러그인
# - v4l-utils: 카메라 장치 확인용 (v4l2-ctl)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Python 기본 환경
        python3 \
        python3-pip \
        python3-full \
        # OpenCV (GStreamer 포함 버전)
        python3-opencv \
        # GStreamer 코어 및 플러그인
        libgstreamer1.0-0 \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-libav \
        gstreamer1.0-tools \
        gstreamer1.0-x \
        gstreamer1.0-alsa \
        gstreamer1.0-gl \
        # 비디오 장치 유틸리티 (라즈베리 파이 카메라 디버깅용)
        v4l-utils \
    && apt-get clean && \

    
    rm -rf /var/lib/apt/lists/* /tmp/*

# 3. Python 패키지 설치
COPY requirements.txt .

# [주의] requirements.txt 안에 'opencv-python'이 있다면 제거해야 합니다.
# 시스템 패키지(apt)로 설치한 OpenCV를 사용하기 위해 pip 설치는 건너뜁니다.
# --break-system-packages: Debian 12부터 시스템 파이썬에 pip 설치 시 필요
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt

# 4. 소스 코드 복사
COPY . .

# 5. 실행 명령
# Debian에서는 'python' 대신 'python3' 명령어를 사용합니다.
CMD ["python3", "script/main.py"]