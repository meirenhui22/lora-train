# 创建目标目录（如果不存在）
$targetDir = "models/flux"
if (-not (Test-Path -Path $targetDir -PathType Container)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
    Write-Host "已创建目标目录: $targetDir"
}

# 检查并安装aria2
Write-Host "检查aria2是否已安装..."
if (-not (Get-Command "aria2c" -ErrorAction SilentlyContinue)) {
    Write-Host "未检测到aria2，开始安装..."
    
    # 检查是否安装了Chocolatey包管理器
    if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
        Write-Host "未检测到Chocolatey包管理器，正在安装..."
        # 安装Chocolatey
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # 刷新环境变量
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
    
    # 使用Chocolatey安装aria2
    choco install -y aria2
    # 再次刷新环境变量
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # 验证安装
    if (-not (Get-Command "aria2c" -ErrorAction SilentlyContinue)) {
        Write-Host "错误：aria2安装失败，请手动安装后重试"
        exit 1
    }
}

Write-Host "开始下载模型文件..."

# 下载各个模型文件
aria2c -x 16 -s 16 -d $targetDir -o flux1-dev.safetensors "https://cnb.cool/itq5/comfyui_models/-/lfs/4610115bb0c89560703c892c59ac2742fa821e60ef5871b33493ba544683abd7?name=flux1-dev.safetensors"

aria2c -x 16 -s 16 -d $targetDir -o clip_l.safetensors "https://cnb.cool/itq5/comfyui_models/-/lfs/660c6f5b1abae9dc498ac2d21e1347d2abdb0cf6c0c0c8576cd796491d9a6cdd?name=clip_l.safetensors"

aria2c -x 16 -s 16 -d $targetDir -o t5xxl_fp16.safetensors "https://cnb.cool/itq5/comfyui_models/-/lfs/6e480b09fae049a72d2a8c5fbccb8d3e92febeb233bbe9dfe7256958a9167635?name=t5xxl_fp16.safetensors"

aria2c -x 16 -s 16 -d $targetDir -o vae.safetensors "https://cnb.cool/itq5/comfyui_models/-/lfs/afc8e28272cd15db3919bacdb6918ce9c1ed22e96cb12c4d5ed0fba823529e38?name=ae.safetensors"

Write-Host "所有模型文件下载完成"
exit 0
    
