#!/bin/sh
set -eu

: "${SECRET:?set SECRET to one or more comma-separated 32-hex-char secrets}"
PORT="${PORT:-443}"
WORKERS="${WORKERS:-1}"

curl -fsS https://core.telegram.org/getProxySecret -o proxy-secret
curl -fsS https://core.telegram.org/getProxyConfig -o proxy-multi.conf

set -- -u nobody -p 8888 -H "$PORT" -M "$WORKERS" --aes-pwd proxy-secret
for secret in $(echo "$SECRET" | tr ',' ' '); do
  set -- "$@" -S "$secret"
done
[ -n "${TAG:-}" ] && set -- "$@" -P "$TAG"
[ -n "${DOMAIN:-}" ] && set -- "$@" -D "$DOMAIN"

# Telegram middle proxies reject the handshake unless we announce the public IP we are reached on.
LOCAL_IP="${LOCAL_IP:-$(hostname -I | cut -d' ' -f1)}"
PUBLIC_IP="${PUBLIC_IP:-$(curl -fsS https://api.ipify.org)}"
set -- "$@" --nat-info "$LOCAL_IP:$PUBLIC_IP"

exec mtproto-proxy "$@" proxy-multi.conf
