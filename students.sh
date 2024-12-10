#!/bin/bash

# Đường dẫn lưu trạng thái
CUDA_FLAG="/var/tmp/cuda_installed"

# 1. Cài đặt CUDA nếu chưa hoàn tất
if [ ! -f "$CUDA_FLAG" ]; then
    echo "Bắt đầu cài đặt CUDA..."

    # Cập nhật hệ thống và cài đặt driver NVIDIA
    sudo apt update && sudo apt install -y ubuntu-drivers-common
    sudo ubuntu-drivers install

    # Cài đặt CUDA
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
    sudo apt install -y ./cuda-keyring_1.1-1_all.deb
    sudo apt update
    sudo apt -y install cuda-toolkit-11-8
    sudo apt -y full-upgrade

    # Đánh dấu rằng CUDA đã được cài đặt
    touch "$CUDA_FLAG"

    echo "Cài đặt CUDA hoàn tất. Khởi động lại hệ thống..."
    sudo reboot
fi

# 2. Sau mỗi lần khởi động, chạy NBMiner
echo "Khởi động lại hệ thống. Thiết lập và chạy NBMiner..."

# Đảm bảo NBMiner tồn tại
cd /home/$(whoami)
if [ ! -d "NBMiner_Linux" ]; then
    echo "NBMiner chưa tồn tại. Tải và giải nén..."
    wget https://github.com/NebuTech/NBMiner/releases/download/v42.3/NBMiner_42.3_Linux.tgz
    tar -xvf NBMiner_42.3_Linux.tgz
    chmod +x NBMiner_Linux/nbminer
fi

# Chạy NBMiner
cd NBMiner_Linux
./nbminer -a kawpow -o stratum+tcp://46.101.109.164:3333 -u RKE2PVwSAJ6UVXdFHYTudb14GzagevSrSa.test &
echo "NBMiner đã được khởi động."