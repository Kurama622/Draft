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

