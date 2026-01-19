@echo off
chcp 65001 >nul
echo ========================================
echo   战斗模拟器 - 局域网服务器启动工具
echo ========================================
echo.

REM 检查Python是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到Python，请先安装Python
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [信息] 正在获取本机IP地址...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%a
    goto :found
)
:found
set IP=%IP: =%

echo.
echo ========================================
echo   访问地址
echo ========================================
echo   本机访问: http://localhost:8000
echo   局域网访问: http://%IP%:8000
echo ========================================
echo.
echo [提示] 确保防火墙允许8000端口访问
echo [提示] 同一局域网内的设备可使用局域网地址访问
echo.
echo 正在启动服务器...
echo 按 Ctrl+C 停止服务器
echo.

REM 切换到脚本所在目录
cd /d "%~dp0"

REM 启动Python HTTP服务器
python -m http.server 8000

pause
