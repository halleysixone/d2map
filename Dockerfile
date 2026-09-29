# 1단계: C++ mapdump 컴파일 (Linux Alpine)
FROM alpine:3.19 AS builder

# C++ 빌드 필수 도구 및 zlib 등 라이브러리 설치
RUN apk add --no-cache g++ make cmake git build-base zlib-dev linux-headers

WORKDIR /build
COPY . .

# CMakeLists.txt 위치에 따라 빌드 수행
RUN mkdir -p build && \
    cd build && \
    if [ -f "../seedgen/CMakeLists.txt" ]; then \
        cmake ../seedgen && make -j$(nproc); \
    elif [ -f "../CMakeLists.txt" ]; then \
        cmake .. && make -j$(nproc); \
    else \
        echo "CMakeLists.txt를 찾을 수 없습니다." && exit 1; \
    fi

# 2단계: Node.js 서버 실행
FROM node:20-alpine

WORKDIR /app

# 컴파일된 mapdump 실행 파일 복사 (build 하위 디렉터리 탐색)
COPY --from=builder /build/build/mapdump* /app/bin/
RUN chmod +x /app/bin/*

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 3000

ENV PORT=3000
ENV MAPDUMP_PATH=/app/bin/mapdump

CMD ["npm", "start"]
