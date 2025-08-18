<#
.SYNOPSIS
根据地区选择合适的源下载Florence-2模型

.DESCRIPTION
该脚本会根据配置的地区（中国或国际）选择合适的源下载模型，并自动处理git-lfs的安装与配置
#>

# 定义变量：是否为中国地区环境（$true/$false）
# 用户可根据实际情况修改此变量
$china = $false

# 目标模型文件夹名称
$targetDir = "Florence-2-large-no-flash-attn"

# 检查目标文件夹是否存在
if (Test-Path -Path $targetDir -PathType Container) {
    Write-Host "检测到模型文件夹已存在：$targetDir"
    Write-Host "无需重复下载，脚本退出"
    exit 0
}

Write-Host "未检测到模型文件夹，开始下载流程..."

# 根据china变量执行对应操作
if ($china) {
    Write-Host "使用中国地区源（modelscope）下载模型"
    $repoUrl = "https://www.modelscope.cn/mirror013/Florence-2-large-no-flash-attn.git"
}
else {
    Write-Host "使用国际源（huggingface）下载模型"
    $repoUrl = "https://huggingface.co/multimodalart/Florence-2-large-no-flash-attn"
}

# 检查并安装git-lfs
Write-Host "检查并安装git-lfs..."
try {
    # 检查git-lfs是否已安装
    if (-not (Get-Command "git-lfs" -ErrorAction SilentlyContinue)) {
        Write-Host "未检测到git-lfs，开始安装..."
        
        # 检查是否安装了choco包管理器
        if (Get-Command "choco" -ErrorAction SilentlyContinue) {
            # 使用choco安装
            choco install -y git-lfs
        }
        else {
            # 直接从官网下载安装
            Write-Host "未检测到choco，从官网下载安装git-lfs..."
            $installerUrl = "https://github.com/git-lfs/git-lfs/releases/latest/download/git-lfs-windows-amd64.exe"
            $installerPath = "$env:TEMP\git-lfs-installer.exe"
            
            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
            Start-Process -FilePath $installerPath -ArgumentList "/verysilent" -Wait
            Remove-Item -Path $installerPath -Force
        }
        
        # 刷新环境变量，使git-lfs可用
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
    
    # 验证git-lfs安装
    if (-not (Get-Command "git-lfs" -ErrorAction SilentlyContinue)) {
        throw "git-lfs安装失败，请手动安装后重试"
    }
}
catch {
    Write-Host "错误：git-lfs安装失败"
    Write-Host "错误信息：$_"
    Write-Host "请检查网络连接或手动安装git-lfs后重试"
    exit 1
}

# 配置git lfs
Write-Host "配置git lfs..."
try {
    git lfs install
    if ($LASTEXITCODE -ne 0) {
        throw "git lfs配置命令执行失败"
    }
}
catch {
    Write-Host "错误：git lfs配置失败"
    Write-Host "错误信息：$_"
    exit 1
}

# 克隆模型仓库
Write-Host "开始克隆模型仓库：$repoUrl"
try {
    git clone $repoUrl
    if ($LASTEXITCODE -ne 0) {
        throw "git克隆命令执行失败"
    }
}
catch {
    Write-Host "错误：模型仓库克隆失败"
    Write-Host "错误信息：$_"
    Write-Host "可能原因：网络连接问题或仓库地址无效"
    exit 1
}

Write-Host "模型下载完成，文件夹路径：$targetDir"
exit 0
