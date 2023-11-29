#!/bin/bash
#当srx对端为动态公网IP且srx没有固定公网IP时，需定时登录至srx防火墙检测 ipsec 状态。
#程序需在srx 对端所在网络运行且能正常登录srx，当检测到ipsec隧道down时，将当前本端的公网IP提交至srx
#运行程序的机器需配置私钥登陆srx
#本程序可根据检查频率在定时任务里定时执行

hxyy_ip=$(wget -q -O - "http://webagent.sangfor.net.cn/webagent/wlan/XXXXX.php?devtype=ap&opt=get_ip" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

myip=$(curl http://myip.ipip.net | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

function get_ipsec_status() {
    ssh -o StrictHostKeyChecking=no -p 1234 id404@$hxyy_ip "show sec ipsec se" | grep tunnels | awk {'print $4'}
}

function fix_ipsec() {
    ssh -o StrictHostKeyChecking=no -p 1234 id404@$hxyy_ip << EOF
    configure
    delete security ike gateway company address
    set security ike gateway company address $myip
    commit comment commit_by_shell_on_docker
    exit
    exit
EOF
}

function send_alarm() {
    curl https://api.day.app/XXXXXXX/hxyy/hxyy_ipsec_down
}



ipsec_status=$(get_ipsec_status)  # 获取 ipsec_status

if [ "$ipsec_status" -eq 0 ]; then

    echo "$(date)  尝试修复工作"
    fix_ipsec
    sleep 150  # 等待修复工作完成

    # 第二次检测 ipsec_status
    ipsec_status=$(get_ipsec_status)

    if [ "$ipsec_status" -eq 0 ]; then
        sleep 1800
        echo "$(date)  尝试第二次修复工作"
        fix_ipsec
        sleep 150
        ipsec_status=$(get_ipsec_status)
        if [ "$ipsec_status" -eq 0 ]; then
            echo "$(date) 修复失败，发送通知动作"
            send_alarm
            break
        fi
    else
        echo "$(date)  ipsec 恢复正常"
    fi

elif [ "$ipsec_status" -eq 1 ]; then
    # 运行正常
    echo "$(date) ipsec 运行正常"

else
    # 其他状态，发送通知
    echo "$(date) IPSec 状态异常，发送通知"
    send_alarm
    # 发送通知的动作
fi
