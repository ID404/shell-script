#!/bin/bash
#当srx对端为动态公网IP且srx没有固定公网IP时，需定时登录至srx防火墙检测 ipsec 状态。
#程序需在srx 对端所在网络运行且能正常登录srx，当检测到ipsec隧道down时，将当前本端的公网IP提交至srx
#运行程序的机器需配置私钥登陆srx
#本程序可根据检查频率在定时任务里定时执行

webagent_url="http://webagent.sangfor.net.cn/webagent/wlan/XXXXX.php?devtype=ap&opt=get_ip"
get_IP_url="http://myip.ipip.net"
ssh_port=1234
ssh_user=id404
alarm_url="https://api.day.app/XXXXXXX/hxyy/hxyy_ipsec_down"
ike_gateway_name=ike_gateway
ipsec_gateway_name=fedi



hxyy_ip=$(wget -q -O - $webagent_url | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
myip=$(curl $get_IP_url | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

function get_ipsec_status() {
    ssh -o StrictHostKeyChecking=no -p $ssh_port $ssh_user@$hxyy_ip "show security ipsec security-associations detail" | grep $ipsec_gateway_name 
}

function fix_ipsec() {
    ssh -o StrictHostKeyChecking=no -p $ssh_port $ssh_user@$hxyy_ip << EOF
    configure
    delete security ike gateway $ike_gateway_name address
    set security ike gateway $ike_gateway_name address $myip
    commit comment commit_by_shell_on_docker
    exit
    exit
EOF
}

function send_alarm() {
    curl $alarm_url
}


MAX_RETRIES=3
retry_count=0
ipsec_status=$(get_ipsec_status)  # 获取 ipsec_status

while [ -z "$ipsec_status" ]; do
    if [ "$retry_count" -eq "$MAX_RETRIES" ]; then
        echo "$(date) $MAX_RETRIES 次修复尝试均失败，发送通知动作"
        send_alarm
        break
    fi

    retry_count=$((retry_count+1))
    echo "$(date)  尝试修复工作 (第 $retry_count 次)"
    fix_ipsec
    sleep 150  # 等待修复工作完成
    ipsec_status=$(get_ipsec_status)
    
done

if [ -n "$ipsec_status"  ]; then
    # 运行正常
    echo "$(date) ipsec 运行正常"
else
    # 其他状态，发送通知
    echo "$(date) IPSec 状态异常，发送通知"
    send_alarm
    # 发送通知的动作
fi
