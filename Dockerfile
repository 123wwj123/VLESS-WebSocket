FROM alpine:latest

# 安装基础工具并下载最新版 Xray-core
RUN apk add --no-cache curl unzip ca-certificates && \
    mkdir -p /etc/xray /usr/local/bin && \
    curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray.zip

COPY config.json /etc/xray/config.json

# 创建启动脚本，支持用环境变量动态覆盖 UUID 和 WS_PATH
RUN printf '#!/bin/sh\n\
sed -i "s|UUID_PLACEHOLDER|${UUID}|g" /etc/xray/config.json\n\
sed -i "s|/ws-stream-8821|${WS_PATH:-/ws-stream-8821}|g" /etc/xray/config.json\n\
exec /usr/local/bin/xray run -c /etc/xray/config.json\n' > /entrypoint.sh && \
chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
