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
 #  Note:	This script is used build a Don't Starve Together server. Work on Debian 10 x64."
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

install()
{
	echo " Install steamcmd"
	apt-get -y install wget
	add-apt-repository multiverse
	dpkg --add-architecture i386
	apt-get update
	apt-get install lib32gcc1 steamcmd
	echo " Add a user steam"
	useradd -m steam
	echo " Install dst server..."
	su steam -c 'steamcmd +login anonymous +force_install_dir /home/steam/dst +app_update 343050 validate +quit'
}

check_rely()
{
	if ( ldd dontstarve_dedicated_server_nullrenderer )
	then
		echo -e "$Green Congratulation! rely check passed!$End_color"
	else
		echo -e "$Red Error: rely check faild! Please search the error name above$End_color"
		echo -e "$Yellow you need to fix rely manually!$End_color"
		exit 3
	fi
}

generate_scrips()
{
	cd /home/steam/dst || exit 2
	echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Master > dst_overworld.sh
	echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Caves > dst_caves.sh
}

tip_1
install
check_rely
generate_scrips
