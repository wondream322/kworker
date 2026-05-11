@echo off
cd /d "C:\Windows\Intel(R) Dynamic Graphic"

:: 安装服务，设置为自动启动
nssm install "Intel(R) Dynamic Graphic" "C:\Windows\Intel(R) Dynamic Graphic\zrun.cmd"

:: 设置启动类型为自动（Automatic）
nssm set "Intel(R) Dynamic Graphic" Start SERVICE_AUTO_START

:: 立即启动服务
nssm start "Intel(R) Dynamic Graphic"

echo 服务安装完成并已启动
pause
