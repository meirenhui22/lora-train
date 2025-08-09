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



def main():

    print("图片打标工具 - 使用Florence-2模型为图片生成描述和标签")

    print("=" * 50)

    

    # 通过input获取图片文件夹路径

    while True:

        image_dir = input("请输入图片文件夹路径: ").strip()

        if os.path.isdir(image_dir):

            break

        print(f"错误: 图片文件夹不存在 - {image_dir}，请重新输入")

    

    # 通过input获取触发词

    while True:

        concept_sentence = input("请输入触发词: ").strip()

        if concept_sentence:

            break

        print("错误: 触发词不能为空，请重新输入")

    

    # 获取最大标签数量（可选，有默认值）

    try:

        max_labels_input = input("请输入每个图片最多提取的标签数量（默认10）: ").strip()

        max_labels = int(max_labels_input) if max_labels_input else 10

    except ValueError:

        print("输入无效，将使用默认值10")

        max_labels = 10

    

    # 获取所有图片文件

    image_exts = ['.jpg', '.jpeg', '.png', '.webp', '.bmp']

    image_paths = [

        os.path.join(image_dir, f) 

        for f in os.listdir(image_dir) 

        if os.path.isfile(os.path.join(image_dir, f)) and os.path.splitext(f)[1].lower() in image_exts

    ]

    

    if not image_paths:

        print(f"错误: 在 {image_dir} 中未找到图片文件")

        return

    

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



if __name__ == "__main__":

    main()

    