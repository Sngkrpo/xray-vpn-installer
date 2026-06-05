#!/usr/bin/env bash
set -euo pipefail

SERVER_IP="${1:-}"
PROFILE_NAME="${2:-VPN}"

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y curl ca-certificates openssl unzip

if ! command -v /usr/local/bin/xray >/dev/null 2>&1; then
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
fi

UUID=$(/usr/local/bin/xray uuid)
KEYS=$(/usr/local/bin/xray x25519)
PRIVATE_KEY=$(printf "%s\n" "$KEYS" | awk -F: '/PrivateKey/ {gsub(/^[ \t]+/, "", $2); print $2}')
PUBLIC_KEY=$(printf "%s\n" "$KEYS" | awk -F: '/PublicKey/ {gsub(/^[ \t]+/, "", $2); print $2}')
SHORT_ID=$(openssl rand -hex 8)

if [ -z "$SERVER_IP" ]; then
  SERVER_IP=$(curl -4 -s https://api.ipify.org || true)
fi

cat > /usr/local/etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "tag": "vless-reality-grpc",
      "listen": "0.0.0.0",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "email": "user@xray"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "www.samsung.com:443",
          "xver": 0,
          "serverNames": [
            "www.samsung.com"
          ],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": [
            "$SHORT_ID"
          ]
        },
        "grpcSettings": {
          "serviceName": "stage",
          "multiMode": false
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls",
          "quic"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "blocked"
    }
  ]
}
EOF

/usr/local/bin/xray run -test -config /usr/local/etc/xray/config.json

systemctl daemon-reload
systemctl enable --now xray
systemctl restart xray

if command -v ufw >/dev/null 2>&1; then
  ufw allow 443/tcp || true
fi

ENCODED_NAME=$(python3 - "$PROFILE_NAME" <<'PY'
import sys
from urllib.parse import quote
print(quote(sys.argv[1], safe=""))
PY
)

echo
echo "Готово!"
echo
echo "vless://${UUID}@${SERVER_IP}:443?encryption=none&security=reality&sni=www.samsung.com&fp=safari&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=grpc&serviceName=stage&mode=gun#${ENCODED_NAME}"
echo
echo "Параметры вручную:"
echo "Address: ${SERVER_IP}"
echo "Port: 443"
echo "UUID: ${UUID}"
echo "Network: gRPC"
echo "Service name: stage"
echo "TLS: Reality"
echo "Fingerprint: Safari"
echo "Server name/SNI: www.samsung.com"
echo "Public key: ${PUBLIC_KEY}"
echo "Short ID: ${SHORT_ID}"
echo "Flow: пусто"
