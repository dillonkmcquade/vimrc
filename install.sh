#!/bin/sh
# This script is for automating installation of programs and repositories for Fedora and
# speeding up the uptime on a fresh install.

if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run with superuser privileges. Re-run command with sudo."
        exit 1
fi
echo '
---------------------------------------------------------------------------

Starting Dillons Fedora bootstrapping script

---------------------------------------------------------------------------

Beginning installscript............

'
read -p "Press y to start: " yesno
if [ "$yesno" != "y" ]
then
        echo 'Exiting program...'
        sleep 1
        exit
fi
echo '
------------------------------------------------------------------------
'
read -p "Update Repos? [y/N]:" starrt
if [ "$starrt" == "y" ]
then
        dnf update -y 
        echo 'Update Successful'
        sleep 2
else 
        echo 'Not updating repos.'
        sleep 2
fi

echo 'adding RPM fusion and proton repos'
dnf install -y -q https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm https://protonvpn.com/download/protonvpn-stable-release-1.0.1-1.noarch.rpm

echo 'Downloading programs......'
#Download brave browser
dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

dnf copr enable flatcap/neomutt
#Download essential programs
BASEDIR=$(dirname $0)
while IFS= read -r line;do
    echo "Installing $line"
    [ -d "${BASEDIR}/$line" ] && cp -r "${BASEDIR}/$line" "$HOME/.config/$line" && echo "Sorting config files for $line"
    [ -f "${BASEDIR}/.${line}rc" ] && cp "${BASEDIR}/.${line}rc" "$HOME/.${line}rc" && echo "Sorting $line to home directory"
    if [ "$line" == "neovim" ]; then
            cp -r "${BASEDIR}/nvim" "$HOME/.config/nvim"
        fi
    dnf install -y -q $line
done < "programs.txt"
echo "
Core programs installed."

#start power-management
tlp start

#Set gtk-theme to dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark

#Reboot system
read -p 'Reboot now? [y/N]: ' reboot
if [ "$reboot" != "y" ]
then
        echo 'complete.'
        exit
else
        echo 'rebooting in 5'
        sleep 5
        reboot
fi
