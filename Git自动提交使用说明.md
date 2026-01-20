# Git自动提交使用说明

## 快速使用

### 方法一：手动运行脚本（推荐）

每次修改文件后，双击运行以下脚本之一：

- **`自动提交到Git.bat`** - Windows批处理脚本（双击即可运行）
- **`自动提交到Git.ps1`** - PowerShell脚本（右键选择"使用PowerShell运行"）

脚本会自动：
1. ✅ 检查是否有更改
2. ✅ 添加所有更改的文件
3. ✅ 提交更改（使用时间戳作为提交信息）
4. ✅ 推送到远程仓库

### 自定义提交信息

在运行脚本时，可以传入自定义的提交信息：

**批处理脚本（.bat）：**
```batch
自动提交到Git.bat "添加了局内战斗模拟页签"
```

**PowerShell脚本（.ps1）：**
```powershell
.\自动提交到Git.ps1 "添加了局内战斗模拟页签"
```

如果不提供参数，脚本会自动使用时间戳作为提交信息。

## 方法二：设置Git Hooks（真正的自动提交）

### 使用pre-commit hook（提交前自动检查）

创建 `.git/hooks/pre-commit` 文件（Windows下需要创建为 `.git/hooks/pre-commit.bat`）：

```batch
@echo off
echo 正在检查代码格式...
REM 这里可以添加代码检查、格式化等操作
exit 0
```

### 使用post-commit hook（提交后自动推送）

创建 `.git/hooks/post-commit` 文件（Windows下需要创建为 `.git/hooks/post-commit.bat`）：

```batch
@echo off
echo 正在推送到远程仓库...
git push origin master 2>nul || git push origin main 2>nul
if errorlevel 1 (
    echo 推送失败，请手动推送
)
```

**注意**：使用hook时，每次`git commit`后会自动推送，但不会自动添加文件，仍需要手动`git add`。

## 方法三：文件监控自动提交（高级）

如果需要真正的"文件保存后自动提交"，可以使用文件监控工具：

### 使用Python脚本监控文件变化

创建 `auto-commit-watcher.py`：

```python
import time
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class GitAutoCommitHandler(FileSystemEventHandler):
    def __init__(self):
        self.last_commit_time = 0
        self.commit_delay = 30  # 30秒内的多次更改只提交一次
    
    def on_modified(self, event):
        if event.src_path.endswith('.html') or event.src_path.endswith('.md'):
            current_time = time.time()
            if current_time - self.last_commit_time > self.commit_delay:
                self.commit_changes()
                self.last_commit_time = current_time
    
    def commit_changes(self):
        try:
            subprocess.run(['git', 'add', '.'], check=True)
            commit_msg = f"自动提交: {time.strftime('%Y-%m-%d %H:%M:%S')}"
            subprocess.run(['git', 'commit', '-m', commit_msg], check=True)
            subprocess.run(['git', 'push'], check=True)
            print(f"✅ 自动提交成功: {commit_msg}")
        except subprocess.CalledProcessError as e:
            print(f"❌ 自动提交失败: {e}")

if __name__ == "__main__":
    event_handler = GitAutoCommitHandler()
    observer = Observer()
    observer.schedule(event_handler, path='.', recursive=False)
    observer.start()
    print("📁 文件监控已启动，文件保存后会自动提交...")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
```

**安装依赖：**
```bash
pip install watchdog
```

**运行：**
```bash
python auto-commit-watcher.py
```

## 推荐工作流程

### 日常开发

1. **修改文件** → 保存
2. **运行脚本** → 双击 `自动提交到Git.bat`
3. **完成** → 更改已自动推送到GitHub

### 批量提交

如果修改了多个文件，可以一次性提交：

```batch
自动提交到Git.bat "更新了多个功能：添加战斗模拟页签、优化属性面板"
```

## 常见问题

### Q1: 推送失败，提示需要身份验证

**解决**：
1. 如果使用HTTPS，需要配置Personal Access Token
2. 如果使用SSH，需要配置SSH密钥
3. 首次推送需要运行 `GitHub-Pages-一键部署.bat` 配置远程仓库

### Q2: 提交信息可以自定义吗？

**可以**：运行脚本时传入参数即可
```batch
自动提交到Git.bat "你的提交信息"
```

### Q3: 如何只提交特定文件？

**方法**：修改脚本，将 `git add .` 改为 `git add 文件名`

或者手动执行：
```batch
git add index.html
git commit -m "更新index.html"
git push
```

### Q4: 如何撤销最后一次提交？

```batch
git reset --soft HEAD~1  # 撤销提交，保留更改
git reset --hard HEAD~1  # 撤销提交，丢弃更改（谨慎使用）
```

## 安全提示

⚠️ **重要**：
- 自动提交会推送所有更改，请确保没有敏感信息
- 建议在提交前检查更改内容
- 可以使用 `git status` 查看将要提交的文件

## 下一步

- ✅ 已创建自动提交脚本
- ✅ 支持自定义提交信息
- ✅ 自动检测并推送更改
- 🔄 如需真正的"保存即提交"，请使用文件监控方案
