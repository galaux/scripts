#! /bin/bash

# Author: Guillaume ALAUX <guillaume alaux dot net>

. /etc/aftergnomeupdate.conf

THIS_VERSION=1
THIS_NAME=$(basename $0 .sh)

# Things to set up after a GDM update
after_gdm_update ()
{
	# Check that we are root
	if [ $(whoami) != "root" ]; then
		echo -e 'You must be root to run this script.\nExiting.'
		exit 1;
	fi
	
	echo 'Setting up GDM configuration...'

	# GDM numlock
	echo -en '\t- GDM numlock'

	GDM_INIT_FILE=/etc/gdm/Init/Default
	NUMLOCK='if [ -x /usr/bin/numlockx ]; then\n\t/usr/bin/numlockx on\nfi'

	if [ $(grep 'numlockx' "$GDM_INIT_FILE" | wc -l) = 0 ]; then
		sed -i "s|^exit 0$|$NUMLOCK\n\n&|" $GDM_INIT_FILE
		echo -e '\t\t\tOK'
	else
		echo -e '\t\t\tAlready OK'
	fi

	# GDM wallpaper
	echo -en '\t- GDM wallpaper'

	#GDM_CONF_FILE=/usr/share/gnome-background-properties/gnome-default.xml
	#WALLPAPER_OLD='/usr/share/pixmaps/backgrounds/gnome/background-default.jpg'
	#WALLPAPER_NEW='/usr/share/pixmaps/backgrounds/gnome/nature/Aqua.jpg'

	#if [ $(grep "$WALLPAPER_OLD" "$GDM_CONF_FILE" | wc -l) -ne 0 ]; then
	#	sed -i "s|$WALLPAPER_OLD|$WALLPAPER_NEW|" $GDM_CONF_FILE
	#	echo -e '\t\t\tOK'
	#else
	#	echo -e '\t\t\tAlready OK'
	#fi

	GCONF_BACKGROUND_KEY="/desktop/gnome/background/picture_filename"
	# GDM_NEW_BACKGROUND: defined in conf file

	if [ $(sudo -u gdm gconftool-2 --get "$GCONF_BACKGROUND_KEY") != "$GDM_NEW_BACKGROUND" ]; then
		sudo -u gdm gconftool-2 --set --type string $GCONF_BACKGROUND_KEY $GDM_NEW_BACKGROUND
		echo -e '\t\t\tOK'
	else
		echo -e '\t\t\tAlready OK'
	fi
}

# Things to set up after a Gnome update
after_gnome_update ()
{
	# Check that we are root
	if [ $(whoami) != "root" ]; then
		echo -e 'You must be root to run this script.\nExiting.'
		exit 1;
	fi
	
	echo 'Setting up Gnome configuration...'

	# Gnome start-here icon
	echo -en "\t- Changing 'start-here' icon"
	
	ICON_OLD_PATH='/usr/share/icons/gnome/24x24/places/start-here.png'
	# ICON_NEW_URL: defiled in conf file

	wget -q "$ICON_NEW_URL"
	if [ ! $(cmp -s "$ICON_OLD_PATH" starthere.png) ]; then
		mv starthere.png  $ICON_OLD_PATH
		pkill gnome-panel

		echo -e '\tOK'
	else
		rm starthere.png
		echo -e '\tAlready OK'
	fi
}

# Prints usage
print_usage ()
{
	echo "$THIS_NAME v$THIS_VERSION"
	echo -e "\n$THIS_NAME [--gdm | --gnome | --all]"
	echo -e "\n\t--gdm\tCustomization of GDM configuration"
	echo -e "\t\t- GDM numlock: automatically switch on numlock in GDM"
	echo -e "\t\t- GDM wallpaper: change GDM wallpaper"
	echo -e "\n\t--gnome\tCustomization of Gnome configuration"
	echo -e "\t\t- Gnome start-here icon: change Gnome's 'foot start-icon'"
	echo -e "\n\t--all\tAll previous customizations"
}

#
# Main
#
case $1 in
	--gdm)
		after_gdm_update
	;;

	--gnome)
		after_gnome_update
	;;

	--all)
		after_gdm_update
		after_gnome_update
	;;

	*)
		print_usage
	;;
esac
