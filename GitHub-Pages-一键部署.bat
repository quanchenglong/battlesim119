@echo off
chcp 65001 >nul
echo ========================================
echo   GitHub Pages 一键部署脚本
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

echo [步骤1/6] 检查Git配置...
git config user.name >nul 2>&1
if errorlevel 1 (
    echo [提示] 首次使用Git，需要配置用户信息
    set /p GIT_USER="请输入GitHub用户名: "
    set /p GIT_EMAIL="请输入GitHub邮箱: "
    git config --global user.name "%GIT_USER%"
    git config --global user.email "%GIT_EMAIL%"
    echo [完成] Git用户信息已配置
) else (
    echo [完成] Git已配置
)
echo.

echo [步骤2/6] 检查Git仓库状态...
if exist .git (
    echo [信息] 已存在Git仓库
) else (
    echo [信息] 初始化Git仓库...
    git init
    echo [完成] Git仓库已初始化
)
echo.

echo [步骤3/6] 添加文件到Git...
git add .
echo [完成] 文件已添加
echo.

echo [步骤4/6] 提交更改...
git commit -m "Deploy to GitHub Pages" 2>nul
if errorlevel 1 (
    echo [提示] 没有新更改需要提交
) else (
    echo [完成] 更改已提交
)
echo.

echo [步骤5/6] 配置远程仓库...
echo [提示] 请确保已在GitHub上创建了仓库
set /p GITHUB_URL="请输入GitHub仓库地址 (例如: https://github.com/用户名/仓库名.git): "
git remote remove origin 2>nul
git remote add origin "%GITHUB_URL%"
echo [完成] 远程仓库已配置
echo.

echo [步骤6/6] 推送到GitHub...
echo [提示] 如果提示输入用户名和密码:
echo        - 用户名: 你的GitHub用户名
echo        - 密码: 使用Personal Access Token (不是GitHub密码)
echo        创建Token: https://github.com/settings/tokens
echo.
git push -u origin main 2>nul
if errorlevel 1 (
    git push -u origin master 2>nul
    if errorlevel 1 (
        echo [错误] 推送失败，请检查:
        echo        1. GitHub仓库地址是否正确
        echo        2. 是否已创建Personal Access Token
        echo        3. 网络连接是否正常
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo   部署完成！
echo ========================================
echo.
echo [下一步] 在GitHub仓库中启用Pages:
echo        1. 进入仓库 Settings
echo        2. 点击左侧 Pages
echo        3. Source 选择 main 分支
echo        4. 点击 Save
echo.
echo [访问地址] 等待1-2分钟后访问:
echo           https://你的用户名.github.io/仓库名/
echo.
pause
