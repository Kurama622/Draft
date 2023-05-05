## [HIP](https://github.com/ROCm-Developer-Tools/HIP)

### 安装
```bash
sudo pacman -S hip-runtime-amd
pushd /opt/rocm/hip/bin
wget https://raw.githubusercontent.com/ROCm-Developer-Tools/HIPIFY/amd-staging/bin/hipify-perl; sudo chmod +x hipify-perl
popd

echo "export HIP_PATH="/opt/rocm/hip\nexport PATH="$PATH:/opt/rocm/bin:$HIP_PATH/bin" > $HOME/.zshrc
source $HOME/.zshrc
```

### 使用

将CUDA代码转换成HIP代码
```bash
hipify-perl test.cu > test.cpp
```

编译HIP代码
```bash
hipcc test.cpp -o test
```
