<!-- vim-markdown-toc GitLab -->

* [伪装tty获取程序输出](#伪装tty获取程序输出)
* [c++自定义内存分配器](#c自定义内存分配器)
* [c++线程池](#c线程池)

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

## c++线程池
### 单任务队列
- c++11
```cpp 
#include <condition_variable>
#include <functional>
#include <future>
#include <memory>
#include <mutex>
#include <queue>
#include <thread>
#include <vector>
#include<iostream>
#include<type_traits>

template<typename F, typename... Args>
struct invoke_result {
  using type = decltype(std::declval<F>()(std::declval<Args>()...));
};

template<typename F, typename... Args>
using invoke_result_t = typename invoke_result<F, Args...>::type;


class ThreadPool {
public:
  explicit ThreadPool(size_t threads = std::thread::hardware_concurrency()) : m_stop(false) {
    // 根据threads数量创建多个线程
    for (size_t i = 0; i < threads; ++i) {
      workers.emplace_back([this]() {

        // 工作线程就是一个死循环，不停查询任务队列并取出任务执行
        while (true) {
          std::unique_lock<std::mutex> lock(this->m_mtx);

          // 条件变量等待线程池不为空或者stop
          this->m_cv.wait(lock, [this]() {
                       return this->m_stop || !this->tasks.empty();
                     });

          // 线程池为空且stop，证明线程池结束，退出线程
          if (this->m_stop && this->tasks.empty())
            return;

          // get task
          std::function<void()> task = std::move(this->tasks.front());
          this->tasks.pop();

          lock.unlock();

          // run task
          task();
        }
      });// lambda表达式构建
    }
  }

  template<typename F, typename... Args>
  auto enqueue(F &&f, Args &&...args) -> std::future<invoke_result_t<F, Args...>> {
    using return_type = invoke_result_t<F, Args...>;
    auto task = std::make_shared<std::packaged_task<return_type()>>(
        std::bind(std::forward<F>(f), std::forward<Args>(args)...));    // 完美转发，构造任务仿函数的指针
    std::future<return_type> res = task->get_future();                  // 获得函数执行的future返回
    {
      std::unique_lock<std::mutex> lock(m_mtx);

      if (m_stop) {
        throw std::runtime_error("enqueue on stopped Thread pool");
      }

      // add task
      tasks.emplace([task = std::move(task)]() { (*task)(); });
    }                                                            // 入队列后即可解锁
    m_cv.notify_one();                                           // 仅唤醒一个线程，避免无意义的竞争
    return res;
  }

  ~ThreadPool() {
    {
      std::unique_lock<std::mutex> lock(m_mtx);
      m_stop = true;
    }
    m_cv.notify_all();// 唤醒所有线程，清理任务
    for (std::thread &worker: workers)
      worker.join();// 阻塞，等待所有线程执行结束
  }

private:
  std::vector<std::thread> workers;
  std::queue<std::function<void()>> tasks;
  std::mutex m_mtx;
  std::condition_variable m_cv;
  bool m_stop;
};

int add(int a, int b) {
  return a + b;
}

void Print() {
  std::cout << "hello world" << std::endl;
}

int main() {
  ThreadPool thread_pool(4);
  for(int i = 0; i < 10; i++) {
    // lambda
    thread_pool.enqueue([i] {
      std::cout << "Task " << i << " is running" << std::endl;
    });

    // non-void function
    // std::cout << thread_pool.enqueue(add, 1, 2).get() << std::endl;

    // void function
    // thread_pool.enqueue(Print);

  }
  std::cin.get();
}

```
