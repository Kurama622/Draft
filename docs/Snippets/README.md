<!-- vim-markdown-toc GitLab -->

* [伪装tty获取程序输出](#伪装tty获取程序输出)
* [c++自定义内存分配器](#c自定义内存分配器)

<!-- vim-markdown-toc -->
## 伪装tty获取程序输出

```cpp
#include <iostream>
#include <string>
#include <pty.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>

FILE* OpenPty(const char* file) {
  int master, slave;
  char name[1024];

  if (openpty(&master, &slave, name, NULL, NULL) == -1) {
    std::cout << "Error: openpty failed!" << std::endl;
    return NULL;
  }

  // fork a child process
  pid_t pid = fork();
  if (pid == 1) {
    std::cout << "Error: fork failed!" << std::endl;
    return NULL;
  }
  else if (pid == 0) {
    // child process: execute shell command
    close(master);
    dup2(slave, STDIN_FILENO);
    dup2(slave, STDOUT_FILENO);
    dup2(slave, STDERR_FILENO);
    execlp("bat", "bat", "--paging=never", "--line-range=0:100", file, NULL);
    exit(0);
  }
  else {
    // parent process: return a FILE* point associated with master end of the pty
    close(slave);
    FILE* f = fdopen(master, "r");
    return f;
  }
}
std::string GetPreviewContext(const char* cmd) {
  char buffer[2];
  size_t len;
  std::string result;
  FILE* f = OpenPty(cmd);
  if (f == NULL) {
    return result;
  }

  // read output from shell command
  try {
    while ((len = fread(buffer, 1, sizeof(buffer), f)) > 0) {
      result += buffer;
    }
  } catch (...) {
    fclose(f);
    throw;
  }
  fclose(f);
  return result;
}

int main() {
  std::cout << GetPreviewContext("./README.md") << std::endl;
}
```

**用处**

1. 获取终端输出的结果时，可以保留其颜色信息

2. 可以实现fzf类似的文本预览效果

## c++自定义内存分配器
```cpp
#include <vector>
#include <iostream>
#include <limits>

// 自定义内存分配器
class MemoryAllocator {
public:
    // 分配内存
    void* allocate(size_t size) {
        void* ptr = malloc(size);
        std::cout << "Allocated: \t" << size << " bytes, \t address: \t" << ptr << std::endl;
        return ptr;
    }

    // 释放内存
    void deallocate(void* ptr, size_t size) {
        std::cout << "Deallocated: \t" << size << " bytes, \t address: \t" << ptr << std::endl;
        free(ptr);
    }
};

// 使用自定义的内存分配器
template <typename T>
class MyAllocator {
public:
    using value_type = T;

    MyAllocator() noexcept {}
    template <typename U> constexpr MyAllocator(const MyAllocator<U>&) noexcept {}

    T* allocate(std::size_t n) {
        if (n > std::numeric_limits<std::size_t>::max() / sizeof(T))
            throw std::bad_alloc();

        return static_cast<T*>(memory_allocator.allocate(n * sizeof(T)));
    }

    void deallocate(T* p, std::size_t n) noexcept {
        memory_allocator.deallocate(p, n * sizeof(T));
    }

private:
    static MemoryAllocator memory_allocator;
};

template <typename T>
MemoryAllocator MyAllocator<T>::memory_allocator;

// 使用自定义的内存分配器分配和释放内存
int main() {
    std::vector<int, MyAllocator<int>> v;

    for (int i = 0; i < 4; ++i) {
      v.push_back(i);
    }

    return 0;
}
```
