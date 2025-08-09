apt-get update
apt-get install aria2 -y
aria2c -x 16 -s 16 -d models/flux -o flux1-fp8-dev.safetensors https://cnb.cool/itq5/comfyui_models/-/lfs/1be961341be8f5307ef26c787199f80bf4e0de3c1c0b4617095aa6ee5550dfce?name=F.1%E5%9F%BA%E7%A1%80%E7%AE%97%E6%B3%95%E6%A8%A1%E5%9E%8B-%E5%93%A9%E5%B8%83%E5%9C%A8%E7%BA%BF%E5%8F%AF%E8%BF%90%E8%A1%8C_F.1-dev-fp8.safetensors
aria2c -x 16 -s 16 -d models/flux -o clip_l.safetensors https://cnb.cool/itq5/comfyui_models/-/lfs/660c6f5b1abae9dc498ac2d21e1347d2abdb0cf6c0c0c8576cd796491d9a6cdd?name=clip_l.safetensors
aria2c -x 16 -s 16 -d models/flux -o t5xxl_fp16.safetensors https://cnb.cool/itq5/comfyui_models/-/lfs/6e480b09fae049a72d2a8c5fbccb8d3e92febeb233bbe9dfe7256958a9167635?name=t5xxl_fp16.safetensors 
aria2c -x 16 -s 16 -d models/flux -o vae.safetensors https://cnb.cool/itq5/comfyui_models/-/lfs/afc8e28272cd15db3919bacdb6918ce9c1ed22e96cb12c4d5ed0fba823529e38?name=ae.safetensors