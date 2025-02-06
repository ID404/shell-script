@echo off

:: 检查是否已以管理员身份运行
net session >nul 2>&1
if %errorLevel% == 0 (
    echo 已以管理员身份运行
) else (
    echo 请求管理员权限
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

goto menu1
 
:menu1
@echo.
@echo.
@echo                ========================================
@echo.
@echo                             1.设置无线网卡
@echo                             2.设置vEthernet
@echo                             3.设置有线网卡
@echo                             4.设置无线网卡D-link
@echo                             5.手动输入网卡名
@echo.
@echo                ========================================
@echo.
@echo                        默认设置无线网卡[直接回车]
@echo.                               
@echo                        请选择[1、2、3、4、5]

set num=1
set /p num=

IF %num%==1 (
set inter=WLAN
goto menu2)

IF %num%==2 (
set inter=vEthernet
goto menu2)

IF %num%==3 (
set inter=以太网
goto menu2)

IF %num%==4 (
set inter=Wi-Fi 2
goto menu2)

IF %num%==5 (
@echo 请输入网卡名
set /p inter=
goto menu2)

IF %nmu% NEQ 5 goto err1

exit

:err1
cls
goto menu1
exit
 


:menu2
@echo.
@echo.
@echo                ========================================
@echo.
@echo                          1. 自动获取ip地址
@echo                          2. 修改ip为192.168.0.128
@echo                          3. 手动输入ip地址
@echo.
@echo                ========================================
@echo. 
@echo                      默认修改ip为自动获取[直接回车]
@echo.
@echo                      请选择[1、2、3]
 
set selc=1
set /p selc=

 
@echo 正在设置...
 
IF %selc%==1 goto DHCP
IF %selc%==2 goto ipstatic 
IF %selc%==3 goto ipsetting
IF %selc% NEQ 2 goto err2
exit
 
 
:err2
cls
goto menu2
exit
 
 
 
:DHCP
@echo.
@echo 自动获取ip地址
netsh int ip set add name="%inter%" source=dhcp
@echo 自动获取DNS服务器
netsh int ip set dns name="%inter%" source=dhcp
@echo 自动获取ip地址设置完毕
@echo.
@echo.
@pause
exit
 
 
 
:ipstatic
@echo 设置为192.168.0.128
netsh int ip set add "%inter%" static 192.168.0.128 255.255.255.0 192.168.0.2 1
@echo 正在设置DNS服务器：8.8.8.8
netsh int ip set dns name="%inter%" source=static 8.8.8.8
netsh int ip add dns name="%inter%" 114.114.114.114 index=2
@echo 静态ip设置完毕
@echo.
@echo.
@pause
exit
 
 
:ipsetting
@echo 正在设置固定ip,请稍候……
@echo.
@echo 请输入ip地址：
set /p ip=
@echo.
@echo.
@echo 请输入网关：
set /p gw=
@echo.
netsh interface ip set address "%inter%" static %ip% 255.255.255.0 %gw% 1

@echo 请输入首选DNS：
set /p DNS1=
@echo.
@echo.
@echo 请输入备用DNS：
set /p DNS2=

netsh interface ip set dns name="%inter%" source=static %DNS1%
netsh int ip add dns name="%inter%" %DNS2% index=2
 
@echo ip地址设置完毕
@echo.
@echo.
@pause
exit
