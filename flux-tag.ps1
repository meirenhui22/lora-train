<#
.SYNOPSIS
图片批量打标工具 - 使用Florence-2模型为图片生成描述和标签

.DESCRIPTION
本脚本通过调用Python执行图片批量打标任务，使用Florence-2模型生成图片描述和标签
并将结果保存为同名的txt文件
#>

# 检查Python是否安装
try {
    python --version 2>&1 | Out-Null
    if (-not $?) { throw }
}
catch {
    Write-Error "未找到Python环境，请先安装Python并确保已添加到系统PATH"
    exit 1
}

# # 检查必要的Python库是否安装
# function Test-PythonPackage {
#     param([string]$PackageName)
#     $result = python -c "import $PackageName" 2>&1
#     return $LASTEXITCODE -eq 0
# }

# # 检查并安装所需的Python库
# $requiredPackages = @("torch", "Pillow", "transformers")
# foreach ($pkg in $requiredPackages) {
#     if (-not (Test-PythonPackage -PackageName $pkg)) {
#         Write-Host "正在安装必要的Python库: $pkg..."
#         pip install $pkg --quiet
#         if (-not (Test-PythonPackage -PackageName $pkg)) {
#             Write-Error "安装Python库 $pkg 失败，请手动安装"
#             exit 1
#         }
#     }
# }

# 创建临时Python脚本
$pythonScript = @'
import os
import torch
from PIL import Image
from transformers import AutoProcessor, AutoModelForCausalLM

# 设置设备（优先使用GPU）
device = "cuda:0" if torch.cuda.is_available() else "cpu"
torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32

def run_captioning(image_path, concept_sentence=None, model=None, processor=None):
    """使用Florence-2模型为单张图片生成详细描述和标签"""
    if model is None or processor is None:
        model = AutoModelForCausalLM.from_pretrained(
            "./Florence-2-large-no-flash-attn",
            torch_dtype=torch_dtype,
            trust_remote_code=True
        ).to(device)
        processor = AutoProcessor.from_pretrained(
            "./Florence-2-large-no-flash-attn",
            trust_remote_code=True
        )
    
    try:
        image = Image.open(image_path).convert("RGB")
        prompt = "<DETAILED_CAPTION>"
        
        inputs = processor(
            text=prompt,
            images=image,
            return_tensors="pt"
        ).to(device, torch_dtype)
        
        generated_ids = model.generate(
            input_ids=inputs["input_ids"],
            pixel_values=inputs["pixel_values"],
            max_new_tokens=1024,
            num_beams=3,
            do_sample=False
        )
        
        generated_text = processor.batch_decode(generated_ids, skip_special_tokens=False)[0]
        parsed_answer = processor.post_process_generation(
            generated_text,
            task=prompt,
            image_size=(image.width, image.height)
        )
        
        caption_text = parsed_answer["<DETAILED_CAPTION>"].replace("The image shows ", "")
        if concept_sentence:
            caption_text = f"{concept_sentence} {caption_text}"
            
        labels = parsed_answer.get("<OD>", {}).get("labels", [])
        
        return {
            "caption": caption_text,
            "labels": labels,
            "image_size": (image.width, image.height)
        }
        
    except Exception as e:
        print(f"处理图片 {image_path} 时出错: {str(e)}")
        return None

def batch_captioning(image_paths, concept_sentence=None, max_labels=10):
    """批量为图片生成描述和标签并保存到txt文件"""
    model = AutoModelForCausalLM.from_pretrained(
        "./Florence-2-large-no-flash-attn",
        torch_dtype=torch_dtype,
        trust_remote_code=True
    ).to(device)
    processor = AutoProcessor.from_pretrained(
        "./Florence-2-large-no-flash-attn",
        trust_remote_code=True
    )
    
    processed_count = 0
    for i, image_path in enumerate(image_paths):
        image_name = os.path.basename(image_path)
        txt_path = os.path.splitext(image_path)[0] + ".txt"
        
        print(f"正在处理图片 {i+1}/{len(image_paths)}: {image_name}")
        
        result = run_captioning(image_path, concept_sentence, model, processor)
        if result:
            # 构建标注文本 - 移除触发词前缀（如果存在）
            caption_text = result["caption"]
            if concept_sentence and caption_text.startswith(concept_sentence):
                caption_text = caption_text[len(concept_sentence):].strip()
            
            # 写入txt文件，格式为：触发词,打标词
            with open(txt_path, 'w', encoding='utf-8') as f:
                f.write(f"{concept_sentence},{caption_text}")
            
            processed_count += 1
            print(f"✓ 已生成标注文件: {os.path.basename(txt_path)}")
    
    # 释放资源
    model.to("cpu")
    del model
    del processor
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
        
    return processed_count

def main(image_dir, concept_sentence, max_labels):
    # 获取所有图片文件
    image_exts = ['.jpg', '.jpeg', '.png', '.webp', '.bmp']
    image_paths = [
        os.path.join(image_dir, f) 
        for f in os.listdir(image_dir) 
        if os.path.isfile(os.path.join(image_dir, f)) and os.path.splitext(f)[1].lower() in image_exts
    ]
    
    if not image_paths:
        print(f"错误: 在 {image_dir} 中未找到图片文件")
        return 0
    
    print(f"\n开始处理 {len(image_paths)} 张图片...")
    print(f"图片文件夹: {image_dir}")
    print(f"触发词: {concept_sentence}")
    print(f"最大标签数量: {max_labels}")
    
    processed_count = batch_captioning(
        image_paths,
        concept_sentence=concept_sentence,
        max_labels=max_labels
    )
    
    print(f"\n完成！共处理 {processed_count} 张图片")
    print(f"标注文件已保存至: {image_dir}")
    return processed_count

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 4:
        print("参数错误")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]))
'@

# 将Python代码写入临时文件
$tempPyFile = [System.IO.Path]::GetTempFileName() -replace '\.tmp$', '.py'
Set-Content -Path $tempPyFile -Value $pythonScript -Encoding utf8

# 主程序交互部分
Write-Host "图片打标工具 - 使用Florence-2模型为图片生成描述和标签"
Write-Host "=" * 50

# 获取图片文件夹路径
do {
    $imageDir = Read-Host "请输入图片文件夹路径"
    $imageDir = $imageDir.Trim()
    if (Test-Path -Path $imageDir -PathType Container) {
        break
    }
    Write-Host "错误: 图片文件夹不存在 - $imageDir，请重新输入"
} while ($true)

# 获取触发词
do {
    $conceptSentence = Read-Host "请输入触发词"
    $conceptSentence = $conceptSentence.Trim()
    if ($conceptSentence -ne "") {
        break
    }
    Write-Host "错误: 触发词不能为空，请重新输入"
} while ($true)

# 获取最大标签数量
do {
    $maxLabelsInput = Read-Host "请输入每个图片最多提取的标签数量（默认10）"
    $maxLabelsInput = $maxLabelsInput.Trim()
    if ($maxLabelsInput -eq "") {
        $maxLabels = 10
        break
    }
    if ($maxLabelsInput -match '^\d+$' -and [int]$maxLabelsInput -gt 0) {
        $maxLabels = [int]$maxLabelsInput
        break
    }
    Write-Host "输入无效，请输入一个正整数"
} while ($true)

# 调用Python脚本执行处理
Write-Host "`n正在启动图片处理程序..."
python $tempPyFile $imageDir $conceptSentence $maxLabels

# 清理临时文件
Remove-Item -Path $tempPyFile -ErrorAction SilentlyContinue

Write-Host "`n程序执行完毕"
    