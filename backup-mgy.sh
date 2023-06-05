#!/bin/bash
#需要提前配置好密钥登陆

echo "----------------------------"
# 设置要ping的IP地址
IP_A="10.0.0.1"
IP_B="10.0.0.4"
echo "开始执行脚本 $(date +%Y%m%d%H%M)"
# 检查IP地址A是否可以ping通
ping -c 1 $IP_A > /dev/null
if [ $? -eq 0 ]; then
  echo "NAS可以ping通"
else
  echo "NAS无法ping通"
  exit 1
fi

/usr/sbin/arp -d 10.0.0.4

# 检查IP地址B是否可以ping通
ping -c 1 $IP_B > /dev/null
if [ $? -eq 0 ]; then
  echo "MGY可以ping通"
else
  echo "MGY无法ping通"
  /usr/sbin/arp -s 10.0.0.4 00:11:22:33:44:55
  exit 1
fi

# 如果两个IP地址都可以ping通  执行下一步操作
echo "两个IP地址都可以ping通，开始检查备份目录挂载"

mount -a
sleep 10

# 检查/backup目录是否存在
if [ ! -d "/mnt/backup-mgy" ]; then
  echo "/backup目录不存在,退出程序"
  /usr/sbin/arp -s 10.0.0.4 00:11:22:33:44:55
  exit 1
fi

# 检查/backup目录是否为空
if [ -z "$(ls -A /mnt/backup-mgy)" ]; then
  echo "/backup目录为空,退出程序"
  /usr/sbin/arp -s 10.0.0.4 00:11:22:33:44:55
  exit 1
fi

# 检查/backup目录是否为挂载点
if ! mountpoint -q /mnt/backup-mgy; then
  echo "/backup目录不是挂载点"
  /usr/sbin/arp -s 10.0.0.4 00:11:22:33:44:55
  exit 1
fi

echo "/backup目录已正确挂载,开始同步备份"



rsync -avz --ignore-existing   --no-owner --no-perms --no-group --include 'mgy*'  backupuser@10.0.0.4:/docker/mysql/backup/destination/  /mnt/backup-mgy/

echo "备份完成"
/usr/sbin/arp -s 10.0.0.4 00:11:22:33:44:55

echo "删除大于14天的备份"
find /mnt/backup-mgy/ -type f -mtime +14 -delete
echo "备份操作完成 $(date +%Y%m%d%H%M)"
echo " "
