# LoRA训练脚本（支持SD、SDXL、Flux）

本项目提供了一套LoRA训练脚本，整合了青龙脚本与秋叶脚本的优势，支持Stable Diffusion (SD)、SDXL、Flux模型的LoRA训练，适配不同显存规格的显卡。


## 目录
- [安装步骤](#安装步骤)
- [训练步骤](#训练步骤)
- [注意事项](#注意事项)


## 安装步骤

### 前置要求
- 操作系统：建议Ubuntu 22.04（适配NVIDIA显卡驱动及CUDA环境）
- 显卡：支持CUDA的NVIDIA显卡（根据训练模型需满足最低显存要求：Flux建议8G及以上，SD/SDXL建议4G及以上）


### 1. 安装环境依赖
执行以下命令安装Python环境、CUDA依赖及训练所需系统库：
```bash
bash install.sh
```
> 脚本内置虚拟环境开关（默认启用），可通过 `USE_VENV=false bash install.sh` 禁用虚拟环境，直接安装到系统环境。


### 2. 安装PowerShell
训练脚本基于PowerShell编写，需先安装PowerShell命令支持：
```bash
bash install-pwsh.sh
```


## 训练步骤

### 1. 准备数据集
- 将数据集（图片）和对应的标签文件（txt格式，与图片同名）上传至路径：  
  `./train/yourname/step_yourname`  
  （其中`yourname`可自定义，用于区分不同训练任务）
- 数据集建议：图片分辨率与目标模型匹配（如SD1.5常用512x512，SDXL常用1024x1024，Flux常用1024x1024），标签需准确描述图片内容。


### 2. 准备基础模型
下载训练所需的基础模型（如SD1.5、SDXL、Flux），并存放至脚本指定的模型路径（可在训练配置文件中修改模型路径）。

- 推荐模型：
  - SD1.5：`v1-5-pruned-emaonly.safetensors`
  - SDXL：`sd_xl_base_1.0.safetensors`
  - Flux：`flux1-dev.safetensors` 或 `flux1-schnell.safetensors`


### 3. 修改训练配置
根据目标模型和显卡显存规格，修改对应的训练配置文件：

- **训练Flux的LoRA**：修改 `train_flux.ps1`  
  支持8G/12G/16G/24G显存显卡，可调整`batch_size`、`gradient_accumulation_steps`等参数适配显存。

- **训练SD1.5的LoRA**：修改 `train_sd15.ps1`  
  主要调整学习率、训练轮数、分辨率等参数。

- **训练SDXL的LoRA**：修改 `train_sdxl.ps1`  
  注意SDXL对显存要求较高，建议调整batch_size以适配显卡。


### 4. 启动训练
根据目标模型执行对应的训练脚本：

- 训练Flux模型的LoRA：
  ```bash
  pwsh train_flux.ps1
  ```

- 训练SD1.5模型的LoRA：
  ```bash
  pwsh train_sd15.ps1
  ```

- 训练SDXL模型的LoRA：
  ```bash
  pwsh train_sdxl.ps1
  ```


## 注意事项
- 训练过程中会生成日志文件和中间模型，可通过日志监控训练进度。
- 若出现显存不足错误，可尝试减小`batch_size`或降低训练分辨率。
- 数据集质量直接影响训练效果，建议预处理图片（如去噪、统一尺寸）并优化标签描述。
- 训练完成后，LoRA模型默认保存至`./output`目录，可用于后续推理或微调。