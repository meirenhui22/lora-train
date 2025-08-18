<#
.SYNOPSIS
安装项目所需的系统和Python依赖

.DESCRIPTION
该脚本会根据操作系统自动安装所需的系统依赖，可选择使用虚拟环境，并安装指定的Python依赖包
#>

# 虚拟环境开关，设置为$true使用虚拟环境，$false则直接安装到系统环境
$USE_VENV = if ($env:USE_VENV) { [bool]::Parse($env:USE_VENV) } else { $true }

# 设置环境变量
$env:HF_HOME = "huggingface"

# 检测操作系统
function Detect-OS {
    $osVersion = [Environment]::OSVersion.VersionString
    if ($osVersion -match "Windows") {
        return "windows"
    }
    elseif ($osVersion -match "Mac OS X") {
        return "macos"
    }
    elseif ($osVersion -match "Linux") {
        # 尝试检测具体的Linux发行版
        if (Test-Path "/etc/os-release") {
            $osRelease = Get-Content "/etc/os-release" | Where-Object { $_ -match "^ID=" }
            if ($osRelease) {
                return $osRelease -replace "ID=", ""
            }
        }
        return "linux"
    }
    else {
        return "unknown"
    }
}

$OS = Detect-OS
Write-Host "Detected operating system: $OS"

# 安装系统依赖
Write-Host "Installing system dependencies..."

switch ($OS) {
    "ubuntu" {
        sudo apt-get update
        sudo apt-get install -y libgl1-mesa-glx build-essential python3-venv
        sudo rm -rf /var/lib/apt/lists/*
    }
    "debian" {
        sudo apt-get update
        sudo apt-get install -y libgl1-mesa-glx build-essential python3-venv
        sudo rm -rf /var/lib/apt/lists/*
    }
    "centos" {
        sudo yum install -y mesa-libGL gcc gcc-c++ python3-venv
        sudo yum clean all
    }
    "rhel" {
        sudo yum install -y mesa-libGL gcc gcc-c++ python3-venv
        sudo yum clean all
    }
    "fedora" {
        sudo yum install -y mesa-libGL gcc gcc-c++ python3-venv
        sudo yum clean all
    }
    "macos" {
        # 检查是否安装了Homebrew
        if (-not (Get-Command "brew" -ErrorAction SilentlyContinue)) {
            Write-Host "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        }
        brew install mesa python3
    }
    "windows" {
        # 检查是否安装了Chocolatey包管理器
        if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
            Write-Host "Installing Chocolatey package manager..."
            Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            
            # 刷新环境变量
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        }
        
        Write-Host "Installing Windows dependencies..."
        choco install -y python3 mesa
    }
    default {
        Write-Host "Unsupported operating system: $OS"
        Write-Host "Please install the following dependencies manually:"
        Write-Host " - OpenGL library (libgl1-mesa-glx on Debian/Ubuntu, mesa-libGL on RHEL/CentOS)"
        Write-Host " - Build tools (build-essential on Debian/Ubuntu, gcc gcc-c++ on RHEL/CentOS)"
        Write-Host " - Python3 and venv module"
        exit 1
    }
}

# 检测Python命令
if (Get-Command "python3" -ErrorAction SilentlyContinue) {
    $PYTHON_CMD = "python3"
}
elseif (Get-Command "python" -ErrorAction SilentlyContinue) {
    $PYTHON_CMD = "python"
}
else {
    Write-Host "Python not found. Please install Python 3 first."
    exit 1
}

# 如果启用虚拟环境
if ($USE_VENV) {
    if (-not (Test-Path "venv" -PathType Container)) {
        Write-Host "Creating venv for python..."
        & $PYTHON_CMD -m venv venv
    }

    Write-Host "Activating virtual environment..."
    # 激活虚拟环境（Windows和其他系统路径不同）
    if ($OS -eq "windows") {
        . .\venv\Scripts\Activate.ps1
    }
    else {
        . ./venv/bin/activate
    }
}

Write-Host "Installing Python dependencies..."

# 安装Python依赖
pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --extra-index-url https://download.pytorch.org/whl/cu128
pip install -U -I --no-deps xformers==0.0.30 --extra-index-url https://download.pytorch.org/whl/cu128
pip install --upgrade -r requirements.txt

Write-Host "Install completed"

# 如果启用了虚拟环境，提示如何退出虚拟环境
if ($USE_VENV) {
    Write-Host "To exit virtual environment, run: deactivate"
}

Read-Host -Prompt "Press Enter to continue..."
    
