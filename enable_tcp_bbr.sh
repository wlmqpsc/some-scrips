#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Red="\\033[31m";
Green="\\033[32m";
Yellow="\\033[33m";
End_color="\\033[0m";

sysctl_conf=/etc/sysctl.conf

author()
{
	echo -e "$Green
 #  This Script Powered By:
 #   _    __ ____ _   __ ______ ______
 #  | |  / //  _// | / // ____// ____/
 #  | | / / / / /  |/ // /    / __/   
 #  | |/ /_/ / / /|  // /___ / /___   
 #  |___//___//_/ |_/ \____//_____/   
 #  
 #  Version:	0.0.1_Alpha
 #  Author:	Vince
 #  Website:	https://www.vincehut.top
 #  Note:	This script is used to enable the tcp bbr! Work on CentOS 8 KVM
 #		Don't try this script on OpenVZ VPS!
$End_color"
}

check_kernel()
{
	echo -e " Your kernel version is 'uname -r'"
	version_1=$(uname -r | awk -F . '{print $1}')
	version_2=$(uname -r | awk -F . '{print $2}')
	if [ "$version_1" -ge 4 ] && [ "$version_2" -ge 9 ]
	then
		echo -e "$Green Great! Your kernel version >= 4.9 $End_color"
	else
		echo -e "$Red Oh no! Your kernel version < 4.9 $End_color"
		echo -e "$Yellow Please upgrade your kernel version and reboot! $End_color"
		exit 2
	fi
}

add_sysctl()
{
	echo " Edit /etc/sysctl.conf"
	echo -e "net.core.default_qdisc=fq" >> "${sysctl_conf}"
	echo -e "net.ipv4.tcp_congestion_control=bbr" >> "${sysctl_conf}"
}

enable_bbr()
{
	sysctl -p
	echo " Now, you can check the bbr."
}
