apt-get update
apt-get install aria2 -y
aria2c -x 16 -s 16 -d models/flux -o flux1-dev.safetensors https://cnb.cool/itq5/comfyui_models/-/lfs/4610115bb0c89560703c892c59ac2742fa821e60ef5871b33493ba544683abd7?name=flux1-dev.safetensors
aria2c -x 16 -s 16 -d models/flux -o clip_l.safetensors https://cnb.cool/itq5/comfyui_models/-/lfs/660c6f5b1abae9dc498ac2d21e1347d2abdb0cf6c0c0c8576cd796491d9a6cdd?name=clip_l.safetensors
aria2c -x 16 -s 16 -d models/flux -o t5xxl_fp16.safetensors https://cnb.cool/itq5/comfyui_models/-/lfs/6e480b09fae049a72d2a8c5fbccb8d3e92febeb233bbe9dfe7256958a9167635?name=t5xxl_fp16.safetensors 
aria2c -x 16 -s 16 -d models/flux -o vae.safetensors https://cnb.cool/itq5/comfyui_models/-/lfs/afc8e28272cd15db3919bacdb6918ce9c1ed22e96cb12c4d5ed0fba823529e38?name=ae.safetensors