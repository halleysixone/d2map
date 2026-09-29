# 1단계: C++ mapdump 컴파일 (Linux)
FROM alpine:latest AS builder

RUN apk add --no-cache g++ make cmake git build-base

WORKDIR /build
COPY . .

# seedgen/mapdump C++ 빌드 수행
RUN mkdir -p seedgen/build && \
    cd seedgen/build && \
    cmake .. && \
    make -j$(nproc)

# 2단계: Node.js API 서버 및 프론트엔드 실행
FROM node:20-alpine

WORKDIR /app

# 컴파일된 mapdump 바이너리 복사
COPY --from=builder /build/seedgen/build/mapdump /app/bin/mapdump
RUN chmod +x /app/bin/mapdump

# Node.js 의존성 및 프론트엔드 빌드
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 3000

ENV PORT=3000
ENV MAPDUMP_PATH=/app/bin/mapdump

CMD ["npm", "start"]
