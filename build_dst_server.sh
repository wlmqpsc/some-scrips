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
 #  Note:	This script is used build a Don't Starve Together server! Work on CentOS 7"
}

tip_1()
{
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
	yum -y update
	yum -y install glibc.i686 libstdc++.i686 wget screen libcurl.i686
	echo " Add a user dst"
	user add -m dst
	sudo su dst
	mkdir steamcmd
	cd steamcmd || exit 2
	echo " Download steam installer..."
	wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
	echo " Decompress steamcmd_linux.tar.gz..."
	sleep 1s
	tar -zxvf steamcmd_linux.tar.gz
	echo " Install dst server..."
	./steamcmd.sh +login anonymous +force_install_dir ~/dst +app_update 343050 validate +quit
}

check_rely()
{
	if ( ldd dontstarve_dedicated_server_nullrenderer )
	then
		echo -e "$Green Congratulation! rely check passed!$End_color"
	else
		echo -e "$Red Error: you need to fix rely manually!$End_color"
		exit 3
	fi
}

generate_config()
{
	cd ~/dst/bin/ || exit 2
	echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Master > dst_overworld.sh
	echo ./dontstarve_dedicated_server_nullrenderer -console -cluster MyDediServer -shard Caves > dst_caves.sh
	sh dst_overworld.sh && sleep 40s
	sh
}
