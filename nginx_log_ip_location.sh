#!/bin/bash
#使用shell脚本分析nginx日志文件中访问ip的地理位置

# 检查是否提供日志文件
if [ -z "$1" ]; then
  echo "使用: $0 文件名"
  exit 1
fi

# 设置日志文件路径和时间范围
LOG_FILE=$1
START_DATE="29/May/2023"
#END_DATE=$(date +"%d/%b/%Y")

#提取日志中的ip地址
awk '{print $1}' $LOG_FILE > ip_temp1.txt

#将IP地址进行统计排序
cat ip_temp1.txt | sort | uniq -c | sort -nr  > iptemp2.txt
rm -rf ip_temp1.txt


#删除内网ip地址及127.0.0.1
awk '$2 !~ /^10\.|^172\.(1[6-9]|2[0-9]|3[01])\.|^192\.168\.|^127\.0\.0\.1/ { print }' iptemp2.txt > iptemp3.txt
rm -rf ip_temp2.txt


#ip地址归属地查询
echo "" > ip_location.txt
while read line
do
  ip_source=$(echo $line | awk '{print $2}')

  location=""

  while [[ -z $location ]]; do

    #方式一，通过nali获取归属地，服务器需提前安装好nali，更新数据库需连网下载，参考https://github.com/zu1k/nali 
    location=$(nali $ip_source | awk '{ $1=""; print $0 }')
    
    #方式二，通过cip.cc/ip获取归属地，需可联网访问cip.cc  
    #location=$(curl cip.cc/$ip_source | grep '数据二' | cut -d ':' -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//')

    if [[ -z $location ]]; then
      echo "Waiting for a result..."
      sleep 1
    fi
  done
  
  echo "$line $location" >> ip_location.txt

  location=""
#awk -v var="$ip_source" '{$3=var; print}' ip_temp2.txt > output.txt
done < iptemp3.txt


rm -rf iptemp3.txt
