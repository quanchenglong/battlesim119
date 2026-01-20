@echo off
chcp 65001 >nul
echo ========================================
echo   自动提交并推送到Git
echo ========================================
echo.

REM 检查Git是否安装
git --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到Git，请先安装Git
    echo 下载地址: https://git-scm.com/downloads
    pause
    exit /b 1
)

REM 检查是否在Git仓库中
if not exist .git (
    echo [错误] 当前目录不是Git仓库
    echo 请先运行 "GitHub-Pages-一键部署.bat" 初始化仓库
    pause
    exit /b 1
)

echo [步骤1/4] 检查更改状态...
git status --short >nul 2>&1
if errorlevel 1 (
    echo [信息] 没有检测到更改
    git status
    pause
    exit /b 0
)

echo [信息] 检测到以下更改:
git status --short
echo.

echo [步骤2/4] 添加所有更改...
git add .
if errorlevel 1 (
    echo [错误] 添加文件失败
    pause
    exit /b 1
)
echo [完成] 文件已添加到暂存区
echo.

echo [步骤3/4] 提交更改...
REM 生成提交信息（包含时间戳）
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set datetime=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2% %datetime:~8,2%:%datetime:~10,2%:%datetime:~12,2%
set commit_msg=自动提交: %datetime%

REM 如果提供了参数，使用参数作为提交信息
if not "%~1"=="" set commit_msg=%~1

git commit -m "%commit_msg%"
if errorlevel 1 (
    echo [错误] 提交失败
    pause
    exit /b 1
)
echo [完成] 更改已提交: %commit_msg%
echo.

echo [步骤4/4] 推送到远程仓库...
REM 先尝试拉取远程更改（如果有）
echo [信息] 检查远程仓库更新...
git fetch origin 2>nul
if errorlevel 1 (
    echo [提示] 无法连接到远程仓库，跳过拉取
) else (
    REM 检查是否有远程更新
    git log HEAD..origin/master --oneline >nul 2>&1
    if not errorlevel 1 (
        echo [警告] 远程仓库有新的提交，需要先拉取
        echo [提示] 正在拉取远程更改...
        git pull origin master --no-rebase 2>nul
        if errorlevel 1 (
            echo [警告] 拉取失败，可能存在冲突，请手动解决后再次运行脚本
            echo [提示] 或者使用: git pull origin master
            pause
            exit /b 1
        )
        echo [完成] 已拉取远程更改
    )
)

REM 尝试推送到main分支
git push origin main 2>nul
if errorlevel 1 (
    REM 如果main分支失败，尝试master分支
    git push origin master 2>nul
    if errorlevel 1 (
        echo [错误] 推送失败，可能的原因:
        echo        1. 远程仓库未配置
        echo        2. 需要身份验证（用户名/Token）
        echo        3. 网络连接问题
        echo        4. 存在冲突需要解决
        echo.
        echo [提示] 如果是首次推送，请先运行 "GitHub-Pages-一键部署.bat" 配置远程仓库
        echo [提示] 如果存在冲突，请先运行: git pull origin master
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo   完成！更改已推送到远程仓库
echo ========================================
echo.
pause
