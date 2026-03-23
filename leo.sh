#!/bin/bash
set -e

LOG_FILE="/root/docker_apps_install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== BAT DAU SETUP $(date) ====="

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl ca-certificates gnupg lsb-release apt-transport-https software-properties-common

# Cai Docker neu chua co
if ! command -v docker >/dev/null 2>&1; then
    curl -fsSL https://get.docker.com | sh
fi

systemctl enable docker
systemctl restart docker

# Cho docker san sang
sleep 5

# Tao device_name ngau nhien cho POP
DEVICE_NAME=$(cat /dev/urandom | LC_ALL=C tr -dc 'A-F0-9' | dd bs=1 count=64 2>/dev/null && echo)

# Xoa container cu neu trung ten
for c in traffmonetizer earnfm castarsdk pop repocket; do
    docker rm -f "$c" >/dev/null 2>&1 || true
done

# Pull image truoc
docker pull traffmonetizer/cli_v2
docker pull earnfm/earnfm-client:latest
docker pull tuanna9414/castarsdk:latest
docker pull tuanna9414/pop:latest

# Chay container
docker run -it -d \
  --name traffmonetizer \
  --restart always \
  --memory=250mb \
  traffmonetizer/cli_v2 start accept --token 7lgEMDR05yqfE7EyW7i0JA7KgMQEIrT0CY1iEq8mx34=

docker run -d \
  --name earnfm \
  --restart=always \
  --memory=100mb \
  -e EARNFM_TOKEN="ddc74367-0a75-4d70-a4e1-fb1f223ee5d2" \
  earnfm/earnfm-client:latest

docker run -d \
  --name castarsdk \
  --restart=always \
  --memory=100mb \
  -e KEY="cskfh95RCwJd04" \
  tuanna9414/castarsdk:latest

docker run -d \
  --name pop \
  --restart=always \
  --memory=100mb \
  -e api_key="RJBNVQRFM6XKIYTQUKNDY0KGW3CP0VQBQWRVF78L" \
  -e device_name="$DEVICE_NAME" \
  tuanna9414/pop:latest

# Luu thong tin ra file
{
  echo "===== CONTAINER STATUS ====="
  docker ps -a
  echo
  echo "DEVICE_NAME_POP=$DEVICE_NAME"
} > /root/docker_apps_status.txt

echo "===== HOAN TAT $(date) ====="
