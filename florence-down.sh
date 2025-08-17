#!/bin/bash

# 定义变量：是否为中国地区环境（true/false）
# 用户可根据实际情况修改此变量
china=false

# 目标模型文件夹名称
target_dir="Florence-2-large-no-flash-attn"

# 检查目标文件夹是否存在
if [ -d "$target_dir" ]; then
    echo "检测到模型文件夹已存在：$target_dir"
    echo "无需重复下载，脚本退出"
    exit 0
fi

echo "未检测到模型文件夹，开始下载流程..."

# 根据china变量执行对应操作
if [ "$china" = true ]; then
    echo "使用中国地区源（modelscope）下载模型"
    repo_url="https://www.modelscope.cn/mirror013/Florence-2-large-no-flash-attn.git"
else
    echo "使用国际源（huggingface）下载模型"
    repo_url="https://huggingface.co/multimodalart/Florence-2-large-no-flash-attn"
fi

# 安装git-lfs（需要root权限，使用sudo）
echo "开始安装git-lfs..."
if ! sudo apt-get update && sudo apt-get install -y git-lfs; then
    echo "错误：git-lfs安装失败"
    echo "请检查网络连接或手动安装git-lfs后重试"
    exit 1
fi

# 配置git lfs
echo "配置git lfs..."
if ! git lfs install; then
    echo "错误：git lfs配置失败"
    exit 1
fi

# 克隆模型仓库
echo "开始克隆模型仓库：$repo_url"
if ! git clone "$repo_url"; then
    echo "错误：模型仓库克隆失败"
    echo "可能原因：网络连接问题或仓库地址无效"
    exit 1
fi

echo "模型下载完成，文件夹路径：$target_dir"
exit 0
