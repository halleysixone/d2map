# 1단계: Debian 기반 Wine 및 Node.js 설치 환경
FROM node:20-slim

# 32비트 아키텍처 추가 및 Wine, 가상 디스플레이(Xvfb) 설치
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wine \
        wine32 \
        xvfb \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 저장소 전체 파일 복사
COPY . .

# renderer 디렉터리로 이동하여 Node.js 의존성 설치 및 빌드
WORKDIR /app/renderer
RUN npm install
RUN npm run build

ENV DISPLAY=:99
ENV WINEDEBUG=-all
ENV PORT=3000

EXPOSE 3000

# renderer 폴더 내의 npm start 스크립트 실행
CMD ["sh", "-c", "Xvfb :99 -screen 0 1024x768x16 & npm start"]
