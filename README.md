# loar-train 项目说明

## 一、项目介绍

loar-train 是一个可训练 sd15、sdxl、flux 的 lora 脚本。

## 二、项目部署

### 2.1 克隆项目



```
git clone https://github.com/meirenhui22/lora-train.git
```

### 2.2 安装依赖

执行以下命令之一：



```
cd lora-train

bash install.sh
```

或



```
cd lora-train

bash install-all.sh
```

### 2.3 安装 pwsh



```
bash install-pwsh.sh
```

### 2.4 安装 florence 的 flux 图片打标模型



```
bash florence-down.sh
```

### 2.5 下载基础模型



*   flux 使用命令：



```
bash flux-model.sh
```



*   sd15 或 sdxl 使用命令：



```
bash sd-model.sh
```

> 若需要更改底模，请进入相应文件修改模型下载链接。

## 三、上传数据集

如要训练刘亦菲的 lora 模型，需上传图片数据集到 `./train/liuyifei/单张图片部数n_body`，例如：



```
./train/liuyifei/20\_body
```

## 四、打标

激活并进入虚拟环境（不同系统命令不同）：



*   flux 使用以下命令打标：



```
pwsh florence-tag.ps1
```



*   sd15 或 sdxl 使用以下命令打标：



```
pwsh sd-tag.ps1
```

## 五、修改参数



*   flux 训练：根据显卡修改不同的 ps1 文件参数


    *   如 8g 显卡，修改文件：`train_flux_8GLora.ps1`

*   sd15 和 sdxl 训练：


    *   修改 `train_sd15.ps1`

    *   修改 `train_sdxl.ps1`

## 六、开始训练



*   flux 训练：根据显卡执行不同的 ps1 文件


    *   如 8g 显卡：



```
pwsh train\_flux\_8GLora.ps1
```



*   sd15 训练执行：



```
pwsh train\_sd15.ps1
```



*   sdxl 训练执行：



```
pwsh train\_sdxl.ps1
```

> （注：文档部分内容可能由 AI 生成）
