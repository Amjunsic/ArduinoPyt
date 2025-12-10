FROM python:3.11-slim-bookworm

WORKDIR /workspace

# 1. 필수 빌드 도구 및 GStreamer 라이브러리 설치 (numpy, python3-dev, python3-distutils 제외)
# GStreamer와 C++ 컴파일에 필요한 도구만 설치합니다.
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    pkg-config \
    python3-dev \
    python3-distutils \
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
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    && rm -rf /var/lib/apt/lists/*

# 1.5. NumPy를 pip로 먼저 설치하여 cmake가 NumPy를 확실히 찾도록 합니다.
COPY requirements.txt .
RUN pip install --no-cache-dir numpy

RUN git clone --depth 1 https://github.com/opencv/opencv.git /opencv

# 2. OpenCV 소스 다운로드 및 빌드 (이전 단계의 경로 명시를 다시 시도합니다)
RUN mkdir /opencv/build && cd /opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_GSTREAMER=ON \
          -D WITH_GSTREAMER_1_0=ON \
          -D OPENCV_GENERATE_PKGCONFIG=ON \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          -D BUILD_opencv_python3=ON \
          \
          # Python 경로를 다시 명시하여 cmake가 정확히 찾도록 유도
          -D PYTHON3_EXECUTABLE=/usr/bin/python3 \
          -D PYTHON3_INCLUDE_DIR=/usr/include/python3.11 \
          -D PYTHON3_LIBRARY=/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/libpython3.11.so \
          -D PYTHON3_PACKAGES_PATH=/usr/local/lib/python3.11/site-packages \
          .. && \
    make -j$(nproc) && make install && \
    rm -rf /opencv

# 3. 나머지 requirements.txt 설치 (pyserial)
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# OpenCV가 공유 라이브러리를 잘 찾도록 설정
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages:$PYTHONPATH

CMD ["python", "lib/main.py"]