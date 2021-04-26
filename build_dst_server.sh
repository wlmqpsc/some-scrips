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
 #  Note:	This script is used build a Don't Starve Together server. Work on Debian 10 x64.$End_color"
}

tip_1()
{
	echo -e "$Yellow This scrip only work on Debian! Do not try on other distribution!$End_color"
	echo -e "$Yellow Do you want to install DST server? [y/N]$End_color"
	read -r answer
	if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
	then
		author
	else
		echo " Exit!" && exit 1
	fi
}

judgement_install()
{
	if [ ! -e "/home/steam/dst/bin/dontstarve_dedicated_server_nullrenderer" ];
	then
		add_nonfree
		are_you_sure
		install
		check_rely
		generate_scrips
		tip_2
	else
		check_rely
		generate_scrips
		tip_2
	fi
}

add_nonfree()
{
	echo -e "$Yellow To install steamcmd, you need to enable non-free packages manually!$End_color"
	echo -e " Open the /etc/apt/sources.list [Y/n]"
	read -r answer
	if [[ "$answer" = "n" ]] || [[ "$answer" =  "no" ]] || [[ "$answer" = "NO" ]] || [[ "$answer" = "N" ]];
	then
		are_you_sure
	else
		nano /etc/apt/sources.list
		are_you_sure
	fi
}

are_you_sure()
{
	echo -e "$Yellow Are you sure you added the non-free? [y/N]$End_color"
	read -r answer
	if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
	then
		echo " Try to install steamcmd"
	else
		echo " Please enable non-free package manually and run this scrip again!" && exit 1
	fi
}

install()
{
	dpkg --add-architecture i386
	apt-get -y update
	apt-get -y install lib32gcc1 steamcmd wget
	echo " Add a user steam"
	useradd -m steam
	echo " Install dst server..."
	su steam -c '/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/dst +app_update 343050 validate +quit'
}

check_rely()
{
	if ldd "/home/steam/dst/bin/dontstarve_dedicated_server_nullrenderer" | grep 'not found' ;
	then
		ldd /home/steam/dst/bin/dontstarve_dedicated_server_nullrenderer
		echo -e "$Red Error: rely check faild! Please search the name which is not found above$End_color"
		echo -e "$Yellow you need to fix dependence error manually!$End_color"
		exit 3
	else
		echo -e "$Green Congratulation! rely check passed!$End_color"
	fi
}

generate_scrips()
{
	cd /home/steam/dst/bin || exit 2
	echo /home/steam/dst/bin/dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Master > dst_overworld.sh
	echo /home/steam/dst/bin/dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Caves > dst_caves.sh
	chmod 775 ./dst_overworld.sh
	chmod 775 ./dst_caves.sh
}

tip_2()
{
	echo -e "$Green Congratulation! you can add your config and run the server!$End_color"
}

######################
#Because every sever need mods and mod config are not same. 
#Even if without mods, different server has different type of game.
#Default DST config is useless.
#Functions below are not finished.
tip_3()
{
	echo -e "$Yellow Do you want to make a default config for your DST server? [y/N]$End_color"
	read -r answer
	if [[ "$answer" = "y" ]] || [[ "$answer" =  "yes" ]] || [[ "$answer" = "YES" ]] || [[ "$answer" = "Y" ]] || [[ "$answer" = "Yes" ]];
	then
		echo " Downloading server config."
	else
		echo " Exit!" && exit 1
	fi
}

get_token()
{
	echo -e " Please input your server token."
	read -r token
	echo -e " Your token is:\n $token"
	echo -e " Is it right? [Y/n]"
	read -r answer
	if [[ "$answer" = "n" ]] || [[ "$answer" =  "no" ]] || [[ "$answer" = "NO" ]] || [[ "$answer" = "N" ]];
	then
	get_token
	fi
}
######################
 
tip_1
judgement_install
