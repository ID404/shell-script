#!/bin/bash

ssh_port=60000
ssh_user=admin
ssh_pass=123456
ssh_IP=1.1.1.1
alarm_url="https://api.day.app/Rf77gV/MSR3620/MSR3620_ipsec_down"



function get_ipsec_status() {
    sshpass -p $ssh_pass ssh -o StrictHostKeyChecking=no -p $ssh_port $ssh_user@$ssh_IP 'dis ipsec sa brief' | grep -a Active
}


function send_alarm() {
    curl $alarm_url
}


#网络连接异常的判定为全部IP测试失败
function internet_check(){
    #测试IP,可写多个
    ip_addresses=("223.5.5.5" "114.114.114.114" "202.96.128.86" "202.96.128.166")
    ping_failed_time=0
    ip_num=${#ip_addresses[@]}
    for ip in "${ip_addresses[@]}"; do
        if ! ping -c 1 "$ip" > /dev/null ; then
        echo "Ping failed for IP: $ip"
        ((ping_failed_time++))
        fi
    done

    if [ $ping_failed_time -eq $ip_num ]; then
        echo "$(date) 网络连接异常"
        echo "$(date) 发送网络异常通知"
        curl -s https://api.day.app/Rf77g/MSR3620/获取本地公网IP异常
        return 1
    else 
        echo "$(date) 网络连接正常"
        return 0
    fi
}

# 检测sshpass命令是否存在
function sshpass_check(){
    if command -v sshpass &> /dev/null
    then
        return 1
    else
        echo "$(date) sshpass未安装,请先安装sshpass,程序将退出"
        exit 1
    fi
}




echo "$(date) 程序开始运行"
sshpass_check
internet_check
internet_status=$?

if [ $internet_status -eq 1 ]; then
    echo  "$(date) 退出检测"
    exit 1
fi


ipsec_status=$(get_ipsec_status)  # 获取 ipsec_status
echo "$(date) ipsec 状态： "
echo "$ipsec_status"

if [ -n "$ipsec_status"  ]; then
    # 运行正常
    echo "$(date) ipsec 运行正常"
else
    # 其他状态，发送通知
    echo "$(date) IPSec 状态异常，发送通知"
    send_alarm
    # 发送通知的动作
fi
