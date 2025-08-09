# 基础镜像：NVIDIA CUDA 12.8 + Ubuntu 22.04（适配H20显卡）
FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

# 安装系统依赖、Python 3.10及新增工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3-pip \
    curl \
    wget \
    unzip \
    git \
    software-properties-common \
    # 新增的系统工具
    libgl1-mesa-glx \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 配置Python 3.10为默认版本
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# 升级pip到最新版本
RUN pip install --upgrade pip

# 安装PowerShell
RUN curl https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -o packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update && apt-get install -y --no-install-recommends \
    powershell \
    && rm -rf /var/lib/apt/lists/*

# 环境变量配置
ENV HF_HOME=/app/huggingface \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
    PYTHONUNBUFFERED=1

# 工作目录
WORKDIR /workspace

# 复制依赖文件
COPY requirements.txt .

# 创建安装脚本（不使用虚拟环境）
RUN echo '#!/usr/bin/pwsh' > install.ps1 \
    && echo '$ErrorActionPreference = "Stop"' >> install.ps1 \
    && echo 'Write-Output "安装Torch+xformers（适配H20显卡）..."' >> install.ps1 \
    && echo 'python -m pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --index-url https://download.pytorch.org/whl/cu128' >> install.ps1 \
    && echo 'python -m pip install -U -I --no-deps xformers==0.0.30 --extra-index-url https://download.pytorch.org/whl/cu128' >> install.ps1 \
    && echo 'Write-Output "安装训练依赖..."' >> install.ps1 \
    && echo 'python -m pip install --upgrade -r requirements.txt' >> install.ps1 \
    && chmod +x install.ps1

# 执行安装
RUN pwsh ./install.ps1

# 创建huggingface缓存目录
RUN mkdir -p $HF_HOME

# 暴露常用端口
EXPOSE 7860 6006

# 默认启动终端
CMD ["bash"]
