#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH


#定义变量
#授权文件自动生成url
APX=http://soft.91yun.org/soft/serverspeeder/apx1.php
#安装包下载地址
INSTALLPACK=http://soft.91yun.org/soft/serverspeeder/91yunserverspeeder.tar.gz
#bin下载地址
BIN=http://soft.91yun.org/soft/serverspeeder/bin/Ubuntu/14.04/3.13.0-24-generic/x64/3.10.61.0/serverspeeder_2620

#安装curl
yum -y install curl || { apt-get update;apt-get install -y curl; } || { echo "curl自动安装失败，请自行手动安装curl后再重新开始";exit 1; }


#先取外网ip，根据取得ip获得网卡，然后通过网卡获得mac地址。
IP=$(curl ipip.net | awk -F ' ' '{print $2}' | awk -F '：' '{print $2}')
NC="ifconfig | awk -F ' |:' '/$IP/{print a}{a=\$1}'"
NETCARD=$(eval $NC)
MACSTR="LANG=C ifconfig $NETCARD | awk '/HWaddr/{ print \$5 }' "
MAC=$(eval $MACSTR)
if [ "$MAC" = "" ]; then
MACSTR="LANG=C ifconfig $NETCARD | awk '/ether/{ print \$2 }' "
MAC=$(eval $MACSTR)
fi
echo IP=$IP
echo NETCARD=$NETCARD
echo MAC=$MAC

#如果自动取不到就要求手动输入
if [ "$MAC" = "" ]; then
echo "无法自动取得mac地址，请手动输入："
read MAC
echo "手动输入的mac地址是$MAC"
fi







	
#下载安装包
echo "======================================"
echo "开始下载安装包。。。。"
echo "======================================"
wget -O 91yunserverspeeder.tar.gz  $INSTALLPACK
tar xfvz 91yunserverspeeder.tar.gz || { echo "下载安装包失败，请检查";exit 1; }

#下载授权文件
echo "======================================"
echo "开始下载授权文件。。。。"
echo "======================================"
curl "$APX?mac=$MAC" -o 91yunserverspeeder/apxfiles/etc/apx-20341231.lic || { echo "下载授权文件失败，请检查";exit 1;}

#取得序列号
echo "======================================"
echo "开始修改配置文件。。。。"
echo "======================================"
SNO=$(curl "$APX?mac=$MAC&sno") || { echo "生成序列号失败，请检查";exit 1; }
echo "序列号：$SNO"
sed -i "s/serial=\"sno\"/serial=\"$SNO\"/g" 91yunserverspeeder/apxfiles/etc/config
rv=Ubuntu_14.04_3.13.0-24-generic
sed -i "s/Debian_7_3.2.0-4-amd64/$rv/g" 91yunserverspeeder/apxfiles/etc/config

#下载bin文件
echo "======================================"
echo "开始下载bin运行文件。。。。"
echo "======================================"
curl $BIN -o 91yunserverspeeder/apxfiles/bin/acce-3.10.61.0-[Ubuntu_14.04_3.13.0-24-generic] || { echo "下载bin运行文件失败，请检查";exit 1; }

#切换目录执安装文件
cd 91yunserverspeeder
bash install.sh

#禁止修改授权文件
chattr +i /serverspeeder/etc/apx*
#安装完显示状态
bash /serverspeeder/bin/serverSpeeder.sh status