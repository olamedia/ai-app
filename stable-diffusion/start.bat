@echo off
cd stable-diffusion-webui

call python -m venv venv
call venv\Scripts\activate.bat
rem call python -c "import torch; print(torch.cuda.is_available())"

set COMMANDLINE_ARGS= --xformers --no-half-vae
call webui-user.bat

cmd /k "%*"
