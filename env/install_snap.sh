#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

Red="\\033[31m";
Green="\\033[32m";
Yellow="\\033[33m";
End_color="\\033[0m";

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
 #  Author:	Vince
 #  Website:	https://www.vincehut.top
 #  Note:	This script is used to install snap
$End_color"
}

tip_0()
{
	echo ""
}

install_snap()
{
	yum install -y epel-release
	yum install -y snapd
	systemctl enable --now snapd.socket
	ln -s /var/lib/snapd/snap /snap
}

tip()
{
	echo -e "Please wait until the snap is ready to use."
}
