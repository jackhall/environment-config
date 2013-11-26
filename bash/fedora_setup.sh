#!/bin/bash
# This script should configure leo from a clean install of Fedora.
# To use on other computers, first modify the filesystem configuration commands or run with a second argument "-nofs"!
# To use: run "sudo ./fedora_setup.sh -first" and wait for reboot. When the system
#	  starts back up, run "sudo ./fedora_setup.sh -second".

ROOT_UID=0
if [ "$UID" -ne "$ROOT_UID" ]
then
	echo "Must be root to run this script."
	exit $E_NOTROOT
fi 

if [ "$1" -eq "first" ]
then
	echo Running system update...
	yum -q -y update

	if [ "$2" -ne "nofs" ]
	then
		echo Configuring filesystem boot behavior...
		if grep -q storage "/etc/fstab"
		then
			echo Filesystem previously configured.
		else
			mkdir /storage
			echo UUID=d5afa2fe-bc30-4a25-96f2-9dc54c965884 /storage		ext4	defaults	1 2 >> /etc/fstab
		fi
	fi

	echo restarting...
	reboot #system needs to switch to newest kernel
fi

if [ "$1" -eq "second" ]
then
	if [ "$2" -ne "nofs" ]
	then
		if [ ! -d "/storage/Documents" ] #tests whether persistent partition mounted
		then
			echo Persistent partition not mounted!
			if grep -q storage "/etc/fstab"
			then
				echo Your current fstab is missing the line for the persistent partition
				cat /etc/fstab
				echo Filesystem boot behavior not configured!
				echo Did you run \"fedora_setup.sh -first\"?
			fi
			exit 1 #tried to configure nonexistent filesystem!
		else
			echo Finishing filesystem configuration...
			if [ ! -h "~/Documents" ]
			then
				cd ~
				rmdir Documents Music Pictures Videos
				ln -s /storage/Documents Documents
				ln -s /storage/Music Music
				ln -s /storage/Pictures Pictures
				ln -s /storage/Videos Videos
			else
				echo Filesystem configuration already finished!
			fi
		fi
	fi

	echo Enabling RPMFusion...
	yum -q -y localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

#echo Installing nvidia proprietary drivers...
#yum -q -y install kmod-nvidia xorg-xll-drv-nvidia-libs

	echo Installing system tools and shell extensions...
	yum -q -y install wget gnome-tweak-tool gnome-shell-extension-common gnome-shell-extension-places-menu gnome-shell-extension-user-theme gnome-shell-extension-mediaplayers gnome-shell-extension-presentation-mode gnome-shell-extension-systemMonitor
	echo note: extensions left to be installed - Multiple Monitor Panels, Advanced Settings in User Menu

	echo Installing and starting Dropbox...
	cd ~
	wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
	~/.dropbox-dist/dropboxd

	echo Installing and configuring coding tools...
	yum -q -y install vim git #general tools
	git config --global user.name "jackhall"
	git config --global user.email "jackwhall7@gmail.com"
	git config --global credential.helper cache
	yum -q -y install xclip
	echo "note: Run \"xclip -sel clip < ~/.ssh/id_rsa.pub\" and paste the results on GitHub"
	mkdir ~/Code
	cd ~/Code
	git clone https://github.com/jackhall/Benoit.git
	cd ~/Code/Benoit
	git submodule update --init
	cd ~/Code
	git clone https://github.com/jackhall/Alexander.git
	git submodule update --init
	cd ~/Code
	git clone https://github.com/jackhall/Lyapunov.git
	git clone https://github.com/mattica/GraphSelfOrganization.git
#git clone https://github.com/jackhall/Wayne.git #has no submodules
	yum -q -y install gcc gcc-c++ make cmake boost boost-devel #c++
	yum -q -y install python-devel python-ipython numpy scipy python-matplotlib #python

	echo Installing office applications...
	yum -q -y install texlive texlive-subfigure texmaker #LaTex
	yum -q -y install libreoffice

	echo Installing multimedia applications and codecs...
	rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
	rpm –import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
	yum -q -y install flash-plugin alsa-plugins-pulseaudio libcurl #flash player (also 2 preceding lines)
	yum -q -y install gstreamer1 gstreamer1-plugins-good gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-libav vlc deluge 

	echo Installing sheet music software...
	yum -q -y install denemo

	echo Done!
	cd ~
	exit 0
fi

