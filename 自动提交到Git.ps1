# PowerShell脚本：自动提交并推送到Git
# 使用方法: .\自动提交到Git.ps1 [提交信息]

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  自动提交并推送到Git" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查Git是否安装
try {
    $gitVersion = git --version 2>&1
    Write-Host "[信息] Git版本: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "[错误] 未检测到Git，请先安装Git" -ForegroundColor Red
    Write-Host "下载地址: https://git-scm.com/downloads" -ForegroundColor Yellow
    Read-Host "按Enter键退出"
    exit 1
}

# 检查是否在Git仓库中
if (-not (Test-Path .git)) {
    Write-Host "[错误] 当前目录不是Git仓库" -ForegroundColor Red
    Write-Host "请先运行 'GitHub-Pages-一键部署.bat' 初始化仓库" -ForegroundColor Yellow
    Read-Host "按Enter键退出"
    exit 1
}

# 步骤1: 检查更改状态
Write-Host "[步骤1/4] 检查更改状态..." -ForegroundColor Cyan
$status = git status --short 2>&1
if ($LASTEXITCODE -ne 0 -or $status.Count -eq 0) {
    Write-Host "[信息] 没有检测到更改" -ForegroundColor Yellow
    git status
    Read-Host "按Enter键退出"
    exit 0
}

Write-Host "[信息] 检测到以下更改:" -ForegroundColor Green
git status --short
Write-Host ""

# 步骤2: 添加所有更改
Write-Host "[步骤2/4] 添加所有更改..." -ForegroundColor Cyan
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 添加文件失败" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}
Write-Host "[完成] 文件已添加到暂存区" -ForegroundColor Green
Write-Host ""

# 步骤3: 提交更改
Write-Host "[步骤3/4] 提交更改..." -ForegroundColor Cyan
$commitMsg = "自动提交: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# 如果提供了参数，使用参数作为提交信息
if ($args.Count -gt 0) {
    $commitMsg = $args[0]
}

git commit -m $commitMsg
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 提交失败" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}
Write-Host "[完成] 更改已提交: $commitMsg" -ForegroundColor Green
Write-Host ""

# 步骤4: 推送到远程仓库
Write-Host "[步骤4/4] 推送到远程仓库..." -ForegroundColor Cyan
$pushSuccess = $false

# 尝试推送到main分支
git push origin main 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    $pushSuccess = $true
} else {
    # 如果main分支失败，尝试master分支
    git push origin master 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        $pushSuccess = $true
    }
}

if (-not $pushSuccess) {
    Write-Host "[错误] 推送失败，可能的原因:" -ForegroundColor Red
    Write-Host "  1. 远程仓库未配置" -ForegroundColor Yellow
    Write-Host "  2. 需要身份验证（用户名/Token）" -ForegroundColor Yellow
    Write-Host "  3. 网络连接问题" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[提示] 如果是首次推送，请先运行 'GitHub-Pages-一键部署.bat' 配置远程仓库" -ForegroundColor Yellow
    Read-Host "按Enter键退出"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  完成！更改已推送到远程仓库" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Read-Host "按Enter键退出"
