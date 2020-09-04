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
 #  Version:	0.1.3_Alpha
 #  Author:	Vince
 #  Website:	https://www.vincehut.top
 #  Note:	This script is used to enable the tcp bbr! Work on CentOS 6+ KVM
 #		Don't try this script on OpenVZ VPS!
$End_color"
}

tip_1()
{
	echo -e "$Yellow Do you want to enable tcp_bbr? [y/N]$End_color    "
	read -r answer
	if [[ "$answer" = "y" ]] || [[ "$answer" = "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
	then
		author
	else
		 echo " Exit!" && exit 1
	fi
}

install_bbr()
{
	check_kernel_version
	add_sysctl
	enable_bbr
}

check_kernel_version()
{
	echo -e " Your kernel version is 'uname -r'"
	version_1=$(uname -r | awk -F . '{print $1}')
	version_2=$(uname -r | awk -F . '{print $2}')
	if [[ "$version_1" -eq 4 ]] && [[ "$version_2" -ge 9 ]] || [[ "$version_1" -ge 4 ]]
	then
		echo -e "$Green Great! Your kernel version >= 4.9 $End_color"
	else
		echo -e "$Red Oh no! Your kernel version < 4.9 $End_color"
		read -r -e -p " Do you want to upgrade kernel now? [Y/n]" answer_1
		if [[ "$answer_1" = "n" ]] || [[ "$answer_1" = "no" ]] || [[ "$answer_1" = "NO" ]] || [[ "$answer_1" = "N" ]];
		then
			exit 1
		else
			check_system_release
			upgrade_kernel
			tip_2
		fi
	fi
}

check_system_release()
{
	system_release=$(rpm -q centos-release | awk -F - '{print $3}')
	if [ "$system_release" -eq 8 ]
	then
		release_x=8
	elif [ "$system_release" -eq 7 ]
	then
		release_x=7
	elif [ "$system_release" -eq 6 ]
	then
		release_x=6
	else
		echo -e "$Red Error: Your system is not support!$End_color"
		exit 2
	fi
	upgrade_kernel
	regenerate_grub_cfg
	tip_2
}

upgrade_kernel()
{
	if [ "$release_x" -eq 8 ]
	then
		upgrade_kernel_8
	elif [ "$release_x" -eq 7 ]
	then
		upgrade_kernel_7
	elif [ "$release_x" -eq 6 ]
	then
		upgrade_kernel_6
	fi
}

upgrade_kernel_8()
{
	echo -e "$Yellow In order to upgrade kernel, do you want to run $Red dnf -y update now?$End_color"
	read -r -e -p " Update system? [y/N]" answer
	if [[ "$answer" = "y" ]] || [[ "$answer" = "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]]; 
	then
		dnf -y update
	else
		exit 1
	fi
}

upgrade_kernel_7()
{
	echo " Intsll elrepo..."
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	yum -y install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
	echo " Update your kernel..."
	yum --enablerepo=elrepo-kernel install kernel-ml -y
}

update_kernel_6()
{
	echo " Intsll elrepo..."
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	yum -y install https://www.elrepo.org/elrepo-release-6.el6.elrepo.noarch.rpm
	echo " Update your kernel..."
	yum --enablerepo=elrepo-kernel install kernel-ml -y
}

regenerate_grub_cfg()
{
	if (command -v grub2-mkconfig &>/dev/null);
	then
		grub2-mkconfig -o /boot/grub2/grub.cfg && grub2-set-default 0
	else
		if (command -v grub-mkconfig &>/dev/null)
		then
			grub-mkconfig -o /boot/grub2/grub.cfg && grub2-set-default 0
		else
			sed -i '/default=/d' /boot/grub/grub.conf && echo -e "ndefault=0c" >> /boot/grub/grub.conf
		fi
	fi
}

tip_2()
{
	echo -e "$Green Upgrade complate! Please reboot your server!\n And run this script again!$End_color"
	exit 0
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
	echo -e "$Green Now, you can check the tcp_bbr!$End_color"
	echo -e "$Green Run some commands to print info..."
	echo "lsmod | grep tcp_bbr"
	echo -e "$(lsmod | grep tcp_bbr)"
	echo "sysctl net.ipv4.tcp_available_congestion_control"
	echo -e "$(sysctl net.ipv4.tcp_available_congestion_control)"
	echo "sysctl net.ipv4.tcp_congestion_control"
	echo -e "$(sysctl net.ipv4.tcp_congestion_control)"
}

tip_1
install_bbr
