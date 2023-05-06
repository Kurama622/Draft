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

## 免费的线上cuda环境

1. 登录[colab](https://colab.research.google.com/)，需要有google账号

2. 更改runtime选项

`Runtime` > `change runtime type` > `GPU`

3. 添加测试代码块

`%%writefile test.cu`会将该代码块后面的代码写入到test.cu文件中

```cpp
%%writefile test.cu
#include <cstdio>
#include <cuda_runtime.h>

__device__ void Print() {
  printf("this is a GPU\n");
}

void kernel_host() {
  printf("this is a CPU\n");
}
__global__ void kernel() {
  Print();
}

int main() {
  kernel<<<1,1>>>();
  cudaDeviceSynchronize();
  kernel_host();
}
```

4. 编译

`!`会运行shell命令，使用`nvcc`编译步骤3中生成的`test.cu`文件

```bash
!nvcc test.cu -o test
```

5. 运行

```bash
!./test
```

**output:**
```
this is a GPU
this is a CPU
```
