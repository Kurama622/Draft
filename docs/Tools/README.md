<!-- vim-markdown-toc GitLab -->

* [程序耗时测量工具](#程序耗时测量工具)
    * [hyperfine](#hyperfine)
        * [安装](#安装)
        * [示例](#示例)
* [查看机器硬件信息](#查看机器硬件信息)
    * [dmidecode](#dmidecode)
        * [安装](#安装-1)
        * [支持的选项](#支持的选项)

<!-- vim-markdown-toc -->

## 程序耗时测量工具

### hyperfine

#### 安装

```bash
sudo pacman -S hyperfine
```

#### 示例

测量zsh的启动时间

```bash
hyperfine "zsh -i -c exit"
```

**结果**

```
Benchmark 1: zsh -i -c exit
  Time (mean ± σ):      19.9 ms ±   0.4 ms    [User: 15.0 ms, System: 6.9 ms]
  Range (min … max):    18.8 ms …  21.0 ms    138 runs
```

## 查看机器硬件信息

### dmidecode

#### 安装

```bash
sudo pacman -S dmidecode
```

#### 支持的选项
<details>
  <summary>点击展开/收起 内容</summary>
    ```bash
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
```
</details>

#### 示例

```bash
sudo dmidecode -t memory
```

**结果**

<details>
  <summary>点击展开/收起 结果</summary>
    ```bash
# dmidecode 3.5
    Getting SMBIOS data from sysfs.
    SMBIOS 3.3.0 present.

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
    ```
</details>

可以看到此电脑最多支持64G的内存，目前安装了2条8G的内存条


### 获取系统的L1_CACHE_LINE

```bash
getconf LEVEL1_DCACHE_LINESIZE
```
