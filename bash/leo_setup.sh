#!/bin/bash
# This script should configure leo from a clean install of Fedora.
# To use on other computers, first modify the filesystem configuration commands or run with a second argument "-nofs"!
# To use: run "sudo ./fedora_setup.sh -first" and wait for reboot. When the system
#	  starts back up, run "sudo ./fedora_setup.sh -second".

ROOT_UID=0
if [ "$UID" != "$ROOT_UID" ]
then
	echo "Must be root to run this script."
	exit $E_NOTROOT
fi 

if [ "$1" == "first" ]
then
	echo "Running system update..."
	yum -q -y update

	if [ "$2" != "nofs" ]
	then
		echo "Configuring filesystem boot behavior..."
		if grep -q storage "/etc/fstab"
		then
			echo "Filesystem previously configured."
		else
			mkdir /storage
			echo UUID=711819297855AD1E /storage		ntfs	defaults	1 2 >> /etc/fstab
		fi
	fi

	echo "restarting..."
	reboot #system needs to switch to newest kernel
fi

if [ "$1" == "second" ]
then
	if [ "$2" != "nofs" ]
	then
		if [ ! -d "/storage/Documents-S" ] #tests whether persistent partition mounted
		then
			echo Persistent partition not mounted!
			if grep -q storage "/etc/fstab"
			then
				echo "Your current fstab is missing the line for the persistent partition"
				cat /etc/fstab
				echo "Filesystem boot behavior not configured!"
				echo "Did you run \"fedora_setup.sh -first\"?"
			fi
			exit 1 #tried to configure nonexistent filesystem!
		else
			echo "Finishing filesystem configuration..."
			if [ ! -h "/home/jack/Documents" ]
			then
				cd /home/jack
				rmdir Documents Music Pictures Videos
				ln -s /storage/Documents-S Documents
				ln -s /storage/Music-S Music
				ln -s /storage/Pictures-S Pictures
				ln -s /storage/Movies-S Videos
			else
				echo "Filesystem configuration already finished!"
			fi
		fi
	fi

	echo "Enabling RPMFusion..."
	yum -q -y localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    echo "Skipping nvidia proprietary drivers."
	#echo "Installing nvidia proprietary drivers..."
	#yum -q -y install kmod-nvidia xorg-xll-drv-nvidia-libs

	echo "Installing system tools..."
	yum -q -y install xfce4-terminal wget gnome-tweak-tool gnome-shell-extension-common gparted readline-devel tmux lm_sensors clamav clamav-update dconf-editor
	echo "note: no extensions installed"

	echo "Installing compilers and interpreters..."
	yum -q -y install gcc gcc-c++ cmake boost boost-devel gtest gtest-devel clang clang-analyzer nemiver #c++
	yum -q -y install python-devel python-ipython numpy scipy python-matplotlib #python
	yum -q -y install chicken chicken-doc cairo cairo-devel SDL SDL-devel SDL_image SDL_image-devel SDL_gfx SDL_gfx-devel SDL_ttf SDL_ttf-devel
	chicken-install readline numbers sdl cairo doodle miscmacros parley simple-graphics
    


	if [ "$3" != "nodropbox" ]
	then
		echo "Installing and starting Dropbox..."
		cd /home/jack
		wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
		chown -R jack /home/jack/Dropbox
		sudo -u jack /home/jack/.dropbox-dist/dropboxd &
		echo ...waiting to sync...
		sleep 5m
	fi

	echo "Installing and configuring coding tools..."
	yum -q -y install vim gvim
	ln -s /home/jack/Dropbox/vim /home/jack/.vim

	echo "Linking to config files in Dropbox..."
	ln -s /home/jack/Dropbox/csirc /home/jack/.csirc
	ln -s /home/jack/Dropbox/inputrc /home/jack/.inputrc
    ln -s /home/jack/Dropbox/tmux.conf /home/jack/.tmux.conf
	ln -s -f /home/jack/Dropbox/ipython /home/jack/.config/.
	ln -s -f /home/jack/Dropbox/bash/bashrc /home/jack/.bashrc

	echo "Installing and configuring git..."
	yum -q -y install git #general tools
	sudo -u jack git config --global user.name "jackhall"
	sudo -u jack git config --global user.email "jackwhall7@gmail.com"
	yum -q -y install xclip
	runuser -l jack -c 'sudo ssh-keygen -t rsa -C "jackwhall7@gmail.com"'
	echo "note: Run \"xclip -sel clip < ~/.ssh/id_rsa.pub\" and paste the results on GitHub"

	echo "Cloning repositories from Github..."
	mkdir /home/jack/Code
	cd /home/jack/Code
	git clone https://github.com/jackhall/Benoit.git
	git clone https://github.com/jackhall/Alexander.git
	cd /home/jack/Code/Alexander
	git submodule update --init
	cd /home/jack/Code
	git clone https://github.com/jackhall/Lyapunov.git
	git clone https://github.com/mattica/GraphSelfOrganization.git
	chown -R jack /home/jack/Code

	echo "Installing office applications..."
	yum -q -y install texlive texlive-subfigure latexmk #LaTex

	echo "Installing multimedia applications and codecs..."
	rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
	rpm –import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
	yum -q -y install flash-plugin icedtea-web alsa-plugins-pulseaudio libcurl #flash player (also 2 preceding lines)
	yum -q -y install gstreamer1 gstreamer1-plugins-good gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-libav vlc deluge 

	echo "Installing sheet music software..."
	yum -q -y install denemo

	echo "Done!"
	cd /home/jack
	exit 0
fi

