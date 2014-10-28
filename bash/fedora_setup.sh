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
            echo UUID=b481582a-00b8-4598-9baa-b1ea1729ca07 /storage     ext4    defaults    1 2 >> /etc/fstab
            # configure TRIM for SSD on '/' and '/home'
            sed -i '\:/\s: s/defaults/defaults,discard/' /etc/fstab
            sed -i '\:/home\s: s/defaults/defaults,discard/' /etc/fstab
		fi
	fi

    echo Disabling log writes on filesystem mount...
    sed -i 's/defaults/defaults,noatime/' /etc/fstab

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
			if [ ! -h "/home/jack/Documents" ]
			then
				cd /home/jack
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

    echo Installing nvidia proprietary drivers...
    yum -q -y install kmod-nvidia xorg-xll-drv-nvidia-libs

	echo Installing system tools and shell extensions...
	yum -q -y install wget tmux gnome-tweak-tool gnome-shell-extension-common gparted readline-devel lm_sensors clamav clamav-update dconf-editor
	echo note: extensions left to be installed - Always New Instance, Advanced Settings in User Menu, User Theme

	# echo Installing and starting Dropbox...
	# cd ~
	# wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
	# ~/.dropbox-dist/dropboxd

    echo Installing office applications...
	yum -q -y install texlive texlive-subfigure latexmk #LaTex
	yum -q -y install libreoffice

	echo Installing multimedia applications and codecs...
	rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
	rpm –import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
	yum -q -y install flash-plugin alsa-plugins-pulseaudio libcurl icedtea-web #flash player (also 2 preceding lines)
	yum -q -y install gstreamer1 gstreamer1-plugins-good gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-libav vlc deluge 

	echo Installing music software...
	yum -q -y install denemo audacity

	echo Installing programming tools...
	yum -q -y install vim git #general tools
	yum -q -y install gcc gcc-c++ make cmake boost boost-devel gtest gtest-devel clang clang-analyzer nemiver #c++
	yum -q -y install python-devel python-ipython numpy scipy python-matplotlib #python
    yum -q -y install chicken chicken-doc cairo cairo-devel SDL SDL-devel SDL_image SDL_image-devel SDL_gfx SDL_gfx-devel SDL_ttf SDL_ttf-devel SDL_net SDL_net-devel
    chicken-install mathh defstruct readline numbers sdl cairo doodle miscmacros parley simple-graphics

    echo Beginning git configuration...
	git config --global user.name "jackhall"
	git config --global user.email "jackwhall7@gmail.com"
    runuser -l jack -c 'ssh-keygen -t rsa -C "jackwhall7@gmail.com"'
	yum -q -y install xclip
	echo "note: Run \"xclip -sel clip < ~/.ssh/id_rsa.pub\" and paste the results on GitHub"
    exit 0
fi

if [ "$1" -eq "third" ]
    echo Cloning repositories from Github...
	mkdir /home/jack/Code
	cd /home/jack/Code
	git clone git@github.com:jackhall/Alexander.git
	git clone git@github.com:jackhall/Lyapunov.git
    git clone git@github.com:jackhall/Georg.git
    git clone git@github.com:jackhall/environment-config
    chown -R jack /home/jack/Code

    echo Linking config files...
    cd /home/jack/Code/environment-config
    ln -s vim /home/jack/.vim
    ln -s ipython /home/jack/.config/.
    ln -s bash/bashrc /home/jack/.bashrc
    ln -s inputrc /home/jack/.inputrc
    ln -s tmux.conf /home/jack/.tmux.conf
    ln -s csirc /home/jack/.csirc

	echo Done!
	exit 0
fi

