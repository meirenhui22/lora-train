#!/bin/bash

# 虚拟环境开关，设置为true使用虚拟环境，false则直接安装到系统环境
USE_VENV=${USE_VENV:-true}

export HF_HOME="huggingface"

# 如果启用虚拟环境
if [ "$USE_VENV" = "true" ]; then
    if [ ! -d "venv" ]; then
        echo "Creating venv for python..."
        python -m venv venv
    fi

    echo "Activating virtual environment..."
    source venv/bin/activate
fi

echo "Installing deps..."

pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --extra-index-url https://download.pytorch.org/whl/cu128
pip install -U -I --no-deps xformers==0.0.30 --extra-index-url https://download.pytorch.org/whl/cu128
pip install --upgrade -r requirements.txt

echo "Install completed"

# 如果启用了虚拟环境，提示如何退出虚拟环境
if [ "$USE_VENV" = "true" ]; then
    echo "To exit virtual environment, run: deactivate"
fi

read -p "Press Enter to continue..."
