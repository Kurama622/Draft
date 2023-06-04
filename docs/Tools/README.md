<!-- vim-markdown-toc GitLab -->

* [程序耗时测量工具](#程序耗时测量工具)
    * [hyperfine](#hyperfine)
        * [安装](#安装)
        * [示例](#示例)
* [查看机器硬件信息](#查看机器硬件信息)
    * [dmidecode](#dmidecode)
        * [安装](#安装-1)
        * [支持的选项](#支持的选项)
    * [获取系统的CACHE_LINE](#获取系统的cache_line)
* [文本搜索工具ripgrep](#文本搜索工具ripgrep)
    * [用法](#用法)

<!-- vim-markdown-toc -->

## 程序耗时测量工具

### hyperfine

#### 安装

```bash
sudo pacman -S hyperfine
```

#### 示例

> 测量zsh的启动时间

```bash
hyperfine "zsh -i -c exit"
```

结果

```
Benchmark 1: zsh -i -c exit
  Time (mean ± σ):      19.9 ms ±   0.4 ms    [User: 15.0 ms, System: 6.9 ms]
  Range (min … max):    18.8 ms …  21.0 ms    138 runs
```

> c++中map的重哈希和vector的内存移动耗时对比

重哈希rehash

```cpp
// rehash.cpp
#include <unordered_map>
#include <string>

int main() {
  std::unordered_map<int, std::string> my_map;
  constexpr int N = 50000;
  for(int i = 0; i < N; ++i) {
    my_map[i] = "hello world hello world hello world \
                 hello world hello world hello world \
                 hello world hello world hello world \
                 hello world hello world hello world \
                 hello world hello world hello world \
                 hello world hello world hello world \
                 hello world hello world hello world \
                 hello world hello world hello world \
                 hello world hello world hello world ";
  }

  return 0;
}
```

内存移动recopy

```cpp
// recopy.cpp
#include <vector>
#include <string>

int main() {
  std::vector<std::string> my_vec;
  constexpr int N = 50000;
  int a[N];
  for(int i = 0; i < N; ++i) {
    my_vec.emplace_back("hello world hello world hello world \
                         hello world hello world hello world \
                         hello world hello world hello world \
                         hello world hello world hello world \
                         hello world hello world hello world \
                         hello world hello world hello world \
                         hello world hello world hello world \
                         hello world hello world hello world \
                         hello world hello world hello world ");

    a[i] = i;
  }
  return 0;
}
```

运行hyperfine

```
hyperfine --warmup=5 "./rehash" "./recopy"
```

结果

```
Benchmark 1: ./rehash
  Time (mean ± σ):      21.5 ms ±   1.0 ms    [User: 13.5 ms, System: 7.8 ms]
  Range (min … max):    20.0 ms …  24.7 ms    126 runs

Benchmark 2: ./recopy
  Time (mean ± σ):      14.8 ms ±   0.9 ms    [User: 7.1 ms, System: 7.6 ms]
  Range (min … max):    13.4 ms …  17.1 ms    162 runs

Summary
  './recopy' ran
    1.45 ± 0.11 times faster than './rehash'
```


## 查看机器硬件信息

### dmidecode

#### 安装

```bash
sudo pacman -S dmidecode
```

#### 支持的选项

<details>
  <summary>点击 展开/收起 内容</summary>
    <pre><code>
Type	Information
0	BIOS
1	System
2	Base Board
3	Chassis
4	Processor
5	Memory Controller
6	Memory Module
7	Cache
8	Port Connector
9	System Slots
10	On Board Devices
11	OEM Strings
12	System Configuration Options
13	BIOS Language
14	Group Associations
15	System Event Log
16	Physical Memory Array
17	Memory Device
18	32-bit Memory Error
19	Memory Array Mapped Address
20	Memory Device Mapped Address
21	Built-in Pointing Device
22	Portable Battery
23	System Reset
24	Hardware Security
25	System Power Controls
26	Voltage Probe
27	Cooling Device
28	Temperature Probe
29	Electrical Current Probe
30	Out-of-band Remote Access
31	Boot Integrity Services
32	System Boot
33	64-bit Memory Error
34	Management Device
35	Management Device Component
36	Management Device Threshold Data
37	Memory Channel
38	IPMI Device
39	Power Supply
40	Additional Information
41	Onboard Device
    </code></pre>
</details>

#### 示例

```bash
sudo dmidecode -t memory
```

结果

<details>
  <summary>点击 展开/收起 结果</summary>
    <pre><code>
Handle 0x0022, DMI type 16, 23 bytes
Physical Memory Array
        Location: System Board Or Motherboard
        Use: System Memory
        Error Correction Type: None
        Maximum Capacity: 64 GB
        Error Information Handle: 0x0025
        Number Of Devices: 2

Handle 0x0023, DMI type 17, 92 bytes
Memory Device
        Array Handle: 0x0022
        Error Information Handle: 0x0026
        Total Width: 64 bits
        Data Width: 64 bits
        Size: 8 GB
        Form Factor: Row Of Chips
        Set: None
        Locator: DIMM 0
        Bank Locator: P0 CHANNEL A
        Type: DDR4
        Type Detail: Synchronous Unbuffered (Unregistered)
        Speed: 3200 MT/s
        Manufacturer: Samsung
        Serial Number: 00000000
        Asset Tag: Not Specified
        Part Number: M471A1G44AB0-CWE
        Rank: 1
        Configured Memory Speed: 3200 MT/s
        Minimum Voltage: 1.2 V
        Maximum Voltage: 1.2 V
        Configured Voltage: 1.2 V
        Memory Technology: DRAM
        Memory Operating Mode Capability: Volatile memory
        Firmware Version: Unknown
        Module Manufacturer ID: Bank 1, Hex 0xCE
        Module Product ID: Unknown
        Memory Subsystem Controller Manufacturer ID: Unknown
        Memory Subsystem Controller Product ID: Unknown
        Non-Volatile Size: None
        Volatile Size: 8 GB
        Cache Size: None
        Logical Size: None

Handle 0x0024, DMI type 17, 92 bytes
Memory Device
        Array Handle: 0x0022
        Error Information Handle: 0x0027
        Total Width: 64 bits
        Data Width: 64 bits
        Size: 8 GB
        Form Factor: Row Of Chips
        Set: None
        Locator: DIMM 0
        Bank Locator: P0 CHANNEL B
        Type: DDR4
        Type Detail: Synchronous Unbuffered (Unregistered)
        Speed: 3200 MT/s
        Manufacturer: Samsung
        Serial Number: 00000000
        Asset Tag: Not Specified
        Part Number: M471A1G44AB0-CWE
        Rank: 1
        Configured Memory Speed: 3200 MT/s
        Minimum Voltage: 1.2 V
        Maximum Voltage: 1.2 V
        Configured Voltage: 1.2 V
        Memory Technology: DRAM
        Memory Operating Mode Capability: Volatile memory
        Firmware Version: Unknown
        Module Manufacturer ID: Bank 1, Hex 0xCE
        Module Product ID: Unknown
        Memory Subsystem Controller Manufacturer ID: Unknown
        Memory Subsystem Controller Product ID: Unknown
        Non-Volatile Size: None
        Volatile Size: 8 GB
        Cache Size: None
        Logical Size: None
</code></pre>
</details>

可以看到此电脑最多支持64G的内存，目前安装了2条8G的内存条


### 获取系统的CACHE_LINE

```bash
getconf LEVEL1_DCACHE_LINESIZE
```

结果

```bash
64
```

## 文本搜索工具ripgrep

替代GNU grep

### 用法

1. 基础用法

```bash 
rg 'keywords'
```

2. 使用正则

```bash
rg -e '[0-9]\.'                 # 查找1., 2.这种形式的文本
rg -e '[0-9]\.' -g 'site/**'    # 在site目录及其子目录下查找1., 2.这种形式的文本
```

3. 搜索单词

```bash
rg -e '\bkey\b'                 # 只查找key这个单词，相当于grep中的grep -E '\<key\>' -rn ./
rg -w 'key'
```

4. 只查找指定文件类型

```bash
rg -t md '\bkey'                # 只在markdown文件中查找
rg -t md -t html '\bkey'        # 只在markdown和html文件中查找
rg -g '*{md, html}' -e '\bkey'  # 只在markdown和html文件中查找
```

5. 过滤文件类型或文件夹

```bash
rg -T html -e '\bkey'           # 不查找html文件
rg -e '\bkey' -g '!site/*'      # 排除site目录
``` 

6. 显示不包含关键词的行

```bash
rg -v 'keywords'
```
