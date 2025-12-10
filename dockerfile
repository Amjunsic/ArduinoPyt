# 기본 이미지: Debian Bookworm 기반 Python 3.11 슬림 버전
FROM python:3.11-slim-bookworm

# 작업 디렉토리 설정
WORKDIR /workspace

# 1. 필수 빌드 도구 및 GStreamer 라이브러리 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    pkg-config \
    python3-dev \
    python3-distutils \
    # GStreamer 라이브러리 및 플러그인
    libglib2.0-0 \
    libgstreamer1.0-0 \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    # FFmpeg 및 이미지 종속성
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    # 라이브러리 캐시 삭제
    && rm -rf /var/lib/apt/lists/*

# requirements.txt 복사 및 Python 종속성 설치 (NumPy 포함)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# OpenCV 소스 다운로드 (최신 버전을 사용하기 위해 depth 1)
RUN git clone --depth 1 https://github.com/opencv/opencv.git /opencv

# 2. OpenCV 빌드 및 설치
RUN mkdir /opencv/build && cd /opencv/build && \
    # Debian 멀티아키텍처 경로 변수 설정
    MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH) && \
    
    echo "--- CMake Configuration ---" && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          \
          # GStreamer 및 빌드 최적화 옵션
          -D WITH_GSTREAMER=ON \
          -D WITH_GSTREAMER_1_0=ON \
          -D OPENCV_GENERATE_PKGCONFIG=ON \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D BUILD_opencv_python3=ON \
          \
          # 🚨 Python 3.11 환경을 명확하게 지정하여 빌드 오류 방지
          -D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python3 \
          -D PYTHON3_EXECUTABLE=/usr/bin/python3 \
          -D PYTHON3_INCLUDE_DIR=/usr/include/python3.11 \
          -D PYTHON3_LIBRARY=/usr/lib/${MULTIARCH}/libpython3.11.so \
          -D PYTHON3_PACKAGES_PATH=/usr/local/lib/python3.11/site-packages \
          .. && \
    
    echo "--- Build and Install ---" && \
    make -j$(nproc) && make install && \
    
    echo "--- Cleaning up Source ---" && \
    rm -rf /opencv

# 3. 설치 검증 단계 (cv2 인식 실패 문제 해결에 도움)
RUN CV2_INSTALL_PATH="/usr/local/lib/python3.11/site-packages/cv2" && \
    if [ -d "$CV2_INSTALL_PATH" ]; then \
        echo "✅ SUCCESS: OpenCV Python module installed at $CV2_INSTALL_PATH"; \
        ls -l $CV2_INSTALL_PATH; \
    else \
        echo "❌ FAILURE: OpenCV Python module directory NOT found at $CV2_INSTALL_PATH. Check CMake logs."; \
        exit 1; \
    fi

# 작업 파일 복사 (앱 코드)
COPY . .

# 4. 환경 변수 설정 (cv2 모듈 및 라이브러리 경로 찾도록 설정)
# GStreamer 종속성 및 OpenCV 라이브러리 경로 추가
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
# cv2 모듈 경로 추가
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages:$PYTHONPATH

# 컨테이너 실행 명령
CMD ["python", "lib/main.py"]