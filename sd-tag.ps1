# tagger script by @bdsqlsz 整合版
# 增加了在标签文件开头添加指定字符串的功能

# Train data path
$chufaci = "bailu," # 请修改为实际需要添加的 触发词+英文逗号
$train_data_dir = "./train/bailu/20_bailu" # input images path | 图片输入路径
$repo_id = "SmilingWolf/wd-eva02-large-tagger-v3" # model repo id from huggingface |huggingface模型repoID
$model_dir = "wd14_tagger_model" # model dir path | 本地模型文件夹路径
$batch_size = 12 # batch size in inference 批处理大小，越大越快
$max_data_loader_n_workers = 0 # enable image reading by DataLoader with this number of workers (faster) | 0最快
$thresh = 0.27 # concept thresh | 最小识别阈值
$general_threshold = 0.27 # general threshold | 总体识别阈值 
$character_threshold = 0.3 # character threshold | 人物姓名识别阈值
$recursive = 1 # search for images in subfolders recursively | 递归搜索下层文件夹，1为开，0为关
$frequency_tags = 0 # order by frequency tags | 从大到小按识别率排序标签，1为开，0为关
$onnx = 1 #使用ONNX模型


#Tag Edit | 标签编辑
$remove_underscore = 1 # remove_underscore | 下划线转空格，1为开，0为关 
$undesired_tags = "simple background" # no need tags | 排除标签
$use_rating_tags = 0 #使用评分标签
$use_rating_tags_as_last_tag= 0 #分类标签放最后
$character_tags_first = 1 #角色标签放在前面
$character_tag_expand = 1 #人物 系列拆分，chara_name_(series) 变为 chara_name, series.
$always_first_tags = "1girl,1boy,2girls,2boys,3girls,3boys" #指定标签放最前，当图像中出现某个标签时，总是先输出该标签。可以指定多个标签，以逗号分隔
$tag_replacement = "" #执行标记替换。指定格式为 tag1,tag2;tag3,tag4。如果使用 , 和 ;，请用\转义。例如，指定 aira tsubase,aira tsubase（uniform）（当您要训练特定服装时）、aira tsubase,aira tsubase\, heir of shadows（当标签中不包括系列名称时）。
$remove_parents_tag = 0

# Activate python venv
Set-Location $PSScriptRoot
if ($env:OS -ilike "*windows*") {
  if (Test-Path "./venv/Scripts/activate") {
    Write-Output "Windows venv"
    ./venv/Scripts/activate
  }
  elseif (Test-Path "./.venv/Scripts/activate") {
    Write-Output "Windows .venv"
    ./.venv/Scripts/activate
  }
}
elseif (Test-Path "./venv/bin/activate") {
  Write-Output "Linux venv"
  ./venv/bin/Activate.ps1
}
elseif (Test-Path "./.venv/bin/activate") {
  Write-Output "Linux .venv"
  ./.venv/bin/activate.ps1
}

$Env:HF_HOME = "huggingface"
$Env:HF_ENDPOINT = "https://hf-mirror.com"
$Env:XFORMERS_FORCE_DISABLE_TRITON = "1"
$ext_args = [System.Collections.ArrayList]::new()

if ($repo_id) {
  [void]$ext_args.Add("--repo_id=$repo_id")
}

if ($model_dir) {
  [void]$ext_args.Add("--model_dir=$model_dir")
}

if ($batch_size) {
  [void]$ext_args.Add("--batch_size=$batch_size")
}

if ($max_data_loader_n_workers) {
  [void]$ext_args.Add("--max_data_loader_n_workers=$max_data_loader_n_workers")
}

if ($general_threshold) {
  [void]$ext_args.Add("--general_threshold=$general_threshold")
}

if ($character_threshold) {
  [void]$ext_args.Add("--character_threshold=$character_threshold")
}

if ($remove_underscore) {
  [void]$ext_args.Add("--remove_underscore")
}

if ($undesired_tags) {
  [void]$ext_args.Add("--undesired_tags=$undesired_tags")
}

if ($recursive) {
  [void]$ext_args.Add("--recursive")
}

if ($frequency_tags) {
  [void]$ext_args.Add("--frequency_tags")
}

if ($onnx) {
  [void]$ext_args.Add("--onnx")
}

if ($character_tags_first) {
  [void]$ext_args.Add("--character_tags_first")
}

if ($character_tag_expand) {
  [void]$ext_args.Add("--character_tag_expand")
}

if ($use_rating_tags) {
  [void]$ext_args.Add("--use_rating_tags")
  if ($use_rating_tags_as_last_tag) {
    [void]$ext_args.Add("--use_rating_tags_as_last_tag")
  }
}

if ($always_first_tags) {
  [void]$ext_args.Add("--always_first_tags=$always_first_tags")
}

if ($tag_replacement) {
  [void]$ext_args.Add("--tag_replacement=$tag_replacement")
}

if ($remove_parents_tag) {
  [void]$ext_args.Add("--remove_parents_tag")
}

# run tagger
accelerate launch --num_cpu_threads_per_process=8 "./sd-scripts/finetune/tag_images_by_wd14_tagger.py" `
  $train_data_dir `
  --thresh=$thresh `
  --caption_extension .txt `
  $ext_args

Write-Output "Tagger finished"

# 新增：在所有标签文件开头添加指定字符串
Write-Output "开始在标签文件开头添加指定内容..."

# 检查目录是否存在
if (-not (Test-Path -Path $train_data_dir -PathType Container)) {
    Write-Error "错误: 目录 '$train_data_dir' 不存在"
    Read-Host | Out-Null
    exit 1
}

# 检查初始字符串是否已设置
if ([string]::IsNullOrEmpty($chufaci)) {
    Write-Warning "警告: 变量 `$chufaci 未定义或为空，跳过添加操作"
    Read-Host | Out-Null
    exit 0
}

# 获取所有TXT文件（根据recursive参数决定是否包含子目录）
if ($recursive) {
    $txtFiles = Get-ChildItem -Path $train_data_dir -Filter *.txt -Recurse -File
} else {
    $txtFiles = Get-ChildItem -Path $train_data_dir -Filter *.txt -File
}

if ($txtFiles.Count -eq 0) {
    Write-Warning "在目录 '$train_data_dir' 中未找到任何TXT文件"
    Read-Host | Out-Null
    exit 0
}

# 遍历每个TXT文件并在开头添加内容
foreach ($file in $txtFiles) {
    try {
        # 读取文件内容
        $content = Get-Content -Path $file.FullName -Raw
        
        # 检查是否已经添加过（避免重复添加）
        if (-not $content.StartsWith($chufaci)) {
            # 在内容开头添加字符串
            $newContent = $chufaci + $content
            
            # 写回文件
            Set-Content -Path $file.FullName -Value $newContent -Force
            
            Write-Host "已处理文件: $($file.FullName)"
        } else {
            Write-Host "文件已包含开头内容，跳过: $($file.FullName)"
        }
    }
    catch {
        Write-Error "处理文件 '$($file.FullName)' 时出错: $_"
    }
}

Write-Host "`n处理完成，共更新了 $($txtFiles.Count) 个文件"
Read-Host | Out-Null
    