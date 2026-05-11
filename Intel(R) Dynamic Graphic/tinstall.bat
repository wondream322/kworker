@echo off
title 创建计划任务 - Intel Dynamic Graphic

set "TASK_NAME=Intel(R) Dynamic Graphic"
set "WORK_DIR=C:\Windows\Intel(R) Dynamic Graphic"
set "EXE_PATH=%WORK_DIR%\Intel(R) Dynamic Graphic.exe"
set "EXE_ARGS=--config=\"%WORK_DIR%\c\""

echo ========================================
echo   创建计划任务
echo ========================================
echo.
echo 任务名称: %TASK_NAME%
echo 程序路径: %EXE_PATH%
echo 启动参数: --config="%WORK_DIR%\c"
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 请以管理员身份运行此脚本
    pause
    exit /b 1
)

:: 删除旧任务（如果存在）
echo [1/4] 清理旧任务...
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo       旧任务已删除
) else (
    echo       无旧任务
)
echo.

:: 创建新任务（系统启动时运行，最高权限）
echo [2/4] 创建计划任务...
schtasks /create /tn "%TASK_NAME%" ^
    /tr "\"%EXE_PATH%\" --config=\"%WORK_DIR%\c\"" ^
    /sc onstart ^
    /ru SYSTEM ^
    /rl HIGHEST ^
    /f

if %errorlevel% neq 0 (
    echo [错误] 任务创建失败
    pause
    exit /b 1
)
echo       任务创建成功
echo.

:: 立即运行测试
echo [3/4] 启动任务...
schtasks /run /tn "%TASK_NAME%"
if %errorlevel% neq 0 (
    echo [警告] 手动启动失败，但开机自启仍有效
) else (
    echo       任务已启动
)
echo.

:: 等待程序启动
echo [4/4] 检查进程...
timeout /t 2 /nobreak >nul

:: 检查进程
tasklist | findstr /i "Intel(R) Dynamic Graphic.exe" >nul
if %errorlevel% equ 0 (
    echo       进程运行中
) else (
    echo       进程未检测到（可能是后台运行或已退出）
)

echo.
echo ========================================
echo   计划任务信息
echo ========================================
schtasks /query /tn "%TASK_NAME%" /fo LIST | findstr /i "TaskName Status"

echo.
echo ========================================
echo   创建完成！
echo ========================================
echo.
echo 管理命令：
echo   手动启动: schtasks /run /tn "%TASK_NAME%"
echo   手动停止: taskkill /f /im "Intel(R) Dynamic Graphic.exe"
echo   查看状态: schtasks /query /tn "%TASK_NAME%" /fo LIST
echo   删除任务: schtasks /delete /tn "%TASK_NAME%" /f
echo.
pause