#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Red="\\033[31m";
Green="\\033[32m";
Yellow="\\033[33m";
End_color="\\033[0m";

SSH_conf="/etc/ssh/sshd_config"

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
 #  Version:  Alpha_0.1.1
 #  Author:   Vince
 #  Website:  https://www.vincehut.top
 #  Note:     This script is used to change the SSH port! Work on CentOS 8
$End_color"
}

tip_1()
{
	echo -e "$Yellow Do you want to change the SSH port? [y/N]$End_color"
	read answer
	if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
	then
		author
	else
		echo " Exit!" && exit 0
	fi
}

choose_function()
{
	echo -e " Which function do you need?"
	echo -e " 1.Add new SSH port"
	echo -e " 2.Close an SSH port"
	read -e -p " Please type the number:" selected
	case $selected in
		1) echo -e " You selected 1\n"
		function_1
		;;
		2) echo -e " You selected 2\n"
		function_2
		;;
		*) echo -e "$Yellow You should select a number above!$End_color"
		;;
	esac
}

function_1()
{
	install_software
	check_system
	scan_config
	read_config
	check_add_input
	add_port
	tip_2
}

function_2()
{
	install_software
	scan_config
	read_config
	tip_3
	check_close_input
	delete_port
	tip_4
}

install_software()
{
	echo " Check and install basic software"
	command -v semanage &>/dev/null
	if [[ $? -ne 0 ]];
	then
		dnf -y install policycoreutils-python-utils
	fi
	command -v lsb_release &>/dev/null
	if [[ $? -ne 0 ]];
	then
		dnf -y install redhat-lsb-core
	fi
}

check_system()
{
	bit=`uname -m`
	echo -e "$Yellow Your system is$End_color `lsb_release -si` $bit."
}

scan_config()
{
	if [ -e ${SSH_conf} ]; 
	then
		echo -e "$Green Find the SSH config!$End_color "
	else
		echo -e "$Red Read the SSH config failed!\n Please check if SSH is installed correctly!$End_color " && exit 1
	fi
}

read_config()
{
	port_read=$(cat ${SSH_conf} | grep -v '#' | grep "Port " | awk '{print $2}')
	if [[ -z ${port_read} ]];
	then
		read_status=1
		port_read=22
	else
		read_status=2
	fi
	echo -e "$Yellow Your SSH port is:\n$End_color$port_read "
}

check_add_input()
{
	while :
	do
		echo -e "$Yellow Use port more than 1000 is suggested!\n Ctrl + c to cancel.$End_color"
		read -e -p " Please input new port[1-65535]:" new_port
		echo $((${new_port}+0)) &>/dev/null
		if [[ $? -eq 0 ]];
 	     	then
			if [[ ${new_port} -ge 1 ]] && [[ ${new_port} -le 65535 ]];
			then
				if [[ ${new_port} = ${read_port} ]];
				then
					echo -e "$Red Error! The new port is the same as the old port!$End_color"
				else
					echo -e "$Yellow New Port: $new_port $End_color"
					break
				fi
			else
				echo -e "$Red Error! Please enter the correct port!$End_color"
			fi
		else
			echo -e "$Red Error! Please enter the correct port!$End_color"
		fi
	done
}

add_port()
{
	echo -e "$Yellow Back up /etc/ssh/sshd_config to /etc/ssh/sshd_config.bak$End_color"
	cp -f "$SSH_conf" "/etc/ssh/sshd_config.bak"
	if [ $read_status -eq 1 ]
	then
		echo -e "Port ${port_read}" >> "${SSH_conf}"
		echo -e "Port ${new_port}" >> "${SSH_conf}"
	else
		echo -e "Port ${new_port}" >> "${SSH_conf}"
	fi
	echo " Add new port to firewalld..."
	firewall-cmd --zone=public --add-port=${new_port}/tcp --permanent
	echo " Reload firewalld..."
	firewall-cmd --reload
	echo -e " Add new port to SE Linux..."
	semanage port -a -t ssh_port_t -p tcp ${new_port}
	echo " Restart sshd..."
	systemctl restart sshd.service
}

tip_2()
{
	echo -e "$Green SSH port has been added successful!$End_color"
	echo -e "$Yelllow Waring: The old port also can be used.$End_color"
	echo -e "$Yellow Please test the new port and use this script to close the old one.$End_color"
	echo " Thanks for use!"
}

tip_3()
{
	echo " Which SSH port do you want to close?"
}

check_close_input()
{
	while :
	do
		read -e -p " Please input a old port:" port_close
		echo $((${port_close}+0)) &>/dev/null
		if [[ $? -eq 0 ]];
 	     	then
			if [[ ${port_close} -ge 1 ]] && [[ ${port_close} -le 65535 ]];
			then
				break
			else
				echo -e "$Red Error! Please enter the correct port!$End_color"
			fi
		else
			echo -e "$Red Error! Please enter the correct port!$End_color"
		fi
	done
}

delete_port()
{
	sed -i "/Port ${port_close}/d" "${SSH_conf}"
	echo " Remove old port from firewalld..."
	firewall-cmd --zone=public --remove-port=${port_close}/tcp --permanent
	echo " Reload firewalld..."
	firewall-cmd --reload
	echo " Remove old port from SE Linux"
	semanage port -d -t ssh_port_t -p tcp ${port_close}
	echo " restart sshd..."
	systemctl restart sshd.service
}

tip_4()
{
	echo -e "$Ywllow The port ${port_close} has been closed!$End_color "
	echo " Thanks for use! "
}

tip_1
choose_function
