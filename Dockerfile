# Debian 기반 32비트/Wine 지원 이미지
FROM node:20-slim

# Wine 및 32비트 라이브러리/멀티아키텍처 설정
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        wine \
        wine32 \
        xvfb \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 저장소 전체 복사
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Wine 실행 환경 설정 (헤드리스)
ENV DISPLAY=:99
ENV WINEDEBUG=-all
ENV PORT=3000

EXPOSE 3000

# Xvfb 가상 디스플레이와 함께 Node 서버 실행
CMD ["sh", "-c", "Xvfb :99 -screen 0 1024x768x16 & node server.js"]
