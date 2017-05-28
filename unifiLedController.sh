#!/bin/bash

# (c) Norbert Kelemen
# This script handle Ubiquit Unifi (R) AP leds (turning on and off)
# sshpass package should be installed

#space separated IP address list
ips=("192.168.1.1" "192.168.1.2")

#UNIFI username
username="username"

#UNIFI password
password="password"

#on hour 24H format (for auto)
onHour="09"

#off hour 24H format (for auto)
offHour="21"

#default we print messages
silent=false

#if -s exist we won't pront messages
if [ "$2" == "-s" ]; then
   	silent=true
fi

#Turning on leds
function turnOn {
	#loop for IP-s
	for ip in "${ips[@]}"
		do
			/usr/bin/sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip  'sed -i 's/mgmt.led_enabled=false/mgmt.led_enabled=true/g' /var/etc/persistent/cfg/mgmt ; exit;'
		done

	#print message if needed
	if [ "$silent" == false ]; then
		echo 'Leds turned ON'
	fi
}

#Turning off leds
function turnOff {
	#loop for IP-s
  	for ip in "${ips[@]}"
 		 do
 			/usr/bin/sshpass -p $password ssh -o StrictHostKeyChecking=no $username@$ip  'sed -i 's/mgmt.led_enabled=true/mgmt.led_enabled=false/g' /var/etc/persistent/cfg/mgmt ; exit';
 	 	done

     #print message if needed
     if [ "$silent" == false ]; then
 		 echo 'Leds turned OFF'
     fi
}

function auto {
	#get system's hour
	hour=$(date +%H)

	#print message if needed
	if [ "$silent" == false ]; then
    		echo 'Automatic (Time: '$hour')'
	fi

	#check hour intervall
	if [ $hour -ge $onHour ] && [ $hour -lt $offHour ]; then
		#turn leds on
		turnOn
	else
		#turn leds off
		turnOff
	fi
}

#Works on Ubuntu/Debian based system
if [ $(lsb_release -si 2>/dev/null) == "Ubuntu" ]; then
	if [ $(dpkg-query -W -f='${Status}' "sshpass" 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
		echo 'Install sshpass package to use this script'
		echo 'apt-get install -y sshpass'
		exit;
	fi
	#Other OS check missing
fi

#main switch
case "$1" in
	"on")
		turnOn
		;;
    "off")
    	turnOff
        ;;
    "auto")
    	auto
        ;;
    "")
    	echo 'Missing attribute (on|off|auto [-s])'
        ;;
    *)
    	echo 'Invalid attribute (on|off|auto [-s])'
        ;;
esac
