#!/bin/bash

# 虚拟环境开关，设置为true使用虚拟环境，false则直接安装到系统环境
USE_VENV=${USE_VENV:-true}

export HF_HOME="huggingface"

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "$ID"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
echo "Detected operating system: $OS"

# 安装系统依赖
echo "Installing system dependencies..."
case $OS in
    ubuntu|debian)
        sudo apt-get update && \
        sudo apt-get install -y libgl1-mesa-glx build-essential python3-venv && \
        sudo rm -rf /var/lib/apt/lists/*
        ;;
    centos|rhel|fedora)
        sudo yum install -y mesa-libGL gcc gcc-c++ python3-venv && \
        sudo yum clean all
        ;;
    macos)
        # 检查是否安装了Homebrew
        if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install mesa python3
        ;;
    *)
        echo "Unsupported operating system: $OS"
        echo "Please install the following dependencies manually:"
        echo " - OpenGL library (libgl1-mesa-glx on Debian/Ubuntu, mesa-libGL on RHEL/CentOS)"
        echo " - Build tools (build-essential on Debian/Ubuntu, gcc gcc-c++ on RHEL/CentOS)"
        echo " - Python3 and venv module"
        exit 1
        ;;
esac

# 检测Python命令
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "Python not found. Please install Python 3 first."
    exit 1
fi

# 如果启用虚拟环境
if [ "$USE_VENV" = "true" ]; then
    if [ ! -d "venv" ]; then
        echo "Creating venv for python..."
        $PYTHON_CMD -m venv venv
    fi

    echo "Activating virtual environment..."
    # 激活虚拟环境（跨平台兼容）
    source venv/bin/activate
fi

echo "Installing Python dependencies..."

# 安装Python依赖
pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --extra-index-url https://download.pytorch.org/whl/cu128
pip install -U -I --no-deps xformers==0.0.30 --extra-index-url https://download.pytorch.org/whl/cu128
pip install --upgrade -r requirements.txt

echo "Install completed"

# 如果启用了虚拟环境，提示如何退出虚拟环境
if [ "$USE_VENV" = "true" ]; then
    echo "To exit virtual environment, run: deactivate"
fi

read -p "Press Enter to continue..."
