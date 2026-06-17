# Xray VPN Installer

Простой установщик Xray VPN для Ubuntu/Debian.

Настройка по умолчанию:

- Protocol: `VLESS`
- Security: `Reality`
- Network: `gRPC`
- Port: `443`
- Service name: `stage`
- SNI: `www.samsung.com`
- Fingerprint: `Safari`
- Flow: пусто

## Быстрая установка

Зайди на сервер по SSH:

```bash
ssh root@IP_СЕРВЕРА
```

Скопируй и вставь команды на сервере. Вставлять можно одним блоком:

```bash
curl -L -o install-xray-reality-grpc.sh https://raw.githubusercontent.com/Sngkrpo/xray-vpn-installer/main/install-xray-reality-grpc.sh
chmod +x install-xray-reality-grpc.sh
./install-xray-reality-grpc.sh IP_СЕРВЕРА "🇺🇸 USA"
```

Для Германии:

```bash
./install-xray-reality-grpc.sh IP_СЕРВЕРА "🇩🇪 Germany"
```

После установки скрипт напечатает ссылку `vless://...`.
Скопируй ее и импортируй в VPN-клиент.

Важно: `IP_СЕРВЕРА` нужно заменить на настоящий IP. Например:

```bash
./install-xray-reality-grpc.sh 45.38.41.24 "🇫🇮 Finland"
```

## Установка с телефона

1. Установи Termius.
2. Подключись к серверу:
   - Host: IP сервера
   - Port: `22`
   - Username: `root`
   - Password: пароль сервера
3. Вставь команды:

```bash
curl -L -o install-xray-reality-grpc.sh https://raw.githubusercontent.com/Sngkrpo/xray-vpn-installer/main/install-xray-reality-grpc.sh
chmod +x install-xray-reality-grpc.sh
./install-xray-reality-grpc.sh IP_СЕРВЕРА "🇺🇸 USA"
```

4. Скопируй ссылку `vless://...` из вывода.
5. Импортируй ссылку в VPN-клиент.

Подробная инструкция лежит в файле:

```text
INSTRUCTION-RU.txt
```

## Проверка

На сервере:

```bash
systemctl status xray --no-pager
ss -lntp | grep ':443'
```

Нужно увидеть:

```text
active (running)
```

и строку с `xray` на порту `443`.

## Примечание

В командах замени только `IP_СЕРВЕРА` на IP своего сервера.

Если после `curl` скачалось всего `14` байт, значит ссылка неправильная и сервер скачал текст `404: Not Found`, а не скрипт.
