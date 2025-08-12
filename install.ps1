# 虚拟环境开关，设置为$true使用虚拟环境，$false则直接安装到系统环境
$USE_VENV = if ($env:USE_VENV) { [bool]::Parse($env:USE_VENV) } else { $true }

$env:HF_HOME = "huggingface"

# 安装系统依赖
Write-Host "Installing system dependencies..."

# 检查是否安装了Chocolatey包管理器
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey package manager not found. Installing Chocolatey..."
    # 安装Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # 刷新环境变量，使choco命令立即可用
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# 安装所需的系统依赖（Windows版本）
choco install -y mesa --no-progress
choco install -y visualcpp-build-tools --no-progress
choco install -y windows-sdk-10.0 --no-progress
choco install -y git --no-progress

# 如果启用虚拟环境
if ($USE_VENV) {
    if (-not (Test-Path "venv")) {
        Write-Host "Creating venv for python..."
        python -m venv venv
    }

    Write-Host "Activating virtual environment..."
    . .\venv\Scripts\Activate.ps1
}

Write-Host "Installing Python dependencies..."

# 安装PyTorch及相关库
pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --extra-index-url https://download.pytorch.org/whl/cu128
pip install -U -I --no-deps xformers==0.0.30 --extra-index-url https://download.pytorch.org/whl/cu128
pip install --upgrade -r requirements.txt

Write-Host "Install completed"

# 如果启用了虚拟环境，提示如何退出虚拟环境
if ($USE_VENV) {
    Write-Host "To exit virtual environment, run: deactivate"
}

Read-Host -Prompt "Press Enter to continue..."
