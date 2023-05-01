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

