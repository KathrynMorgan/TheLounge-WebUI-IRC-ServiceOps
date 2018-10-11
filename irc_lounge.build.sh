#!/bin/bash

# This is a rough un-tested bash script, use with caution!!!!
# Pre-Alpha code template
# Sketch only material at this time

# This is an LXD setup script for "The Lounge" IRC Client
# It is intended to run on a local server so that you can use via web browser
# Default listening port is 9000

# Add system user "lounge"
echo "Creating New User: loungeadmin"
echo "Please provide a password for loungeadmin"
adduser loungeadmin

# Curl install npm7
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
apt update
apt install -y nodejs libcap2-bin build-essential
npm install -g thelounge

# set rc.local to initialize the lounge on startup

cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

sudo -H -u loungeadmin bash -c "thelounge start"
exit 0

EOF

# Check if rc.local is enabled & warn if not enalbed
check_RC_IS_ENABLED=$(systemctl is-enabled rc.local.service)
if [ $check_RC_IS_ENABLED = "1" ]; then
systemctl enable rc.local.service
echo "WARNING: rc.local service MAY NOT ENABLED on this server"
echo "WARNING: lounge IRC client will NOT start on reboot unless 
               rc.local.service is enabled"
fi

# Start thelounge service as loungeadmin user
echo "Starting The Lounge as user \'loungeadmin\'"
sudo -H -u loungeadmin bash -c "thelounge start &" 
sleep 1
sudo -H -u loungeadmin bash -c "thelounge status"

# Prep for new thelounge user creation
read -rp "
Please create username for your first The Lounge Web login
NEW USER NAME: " thelounge_USER;

# Create first thelounge web user
sudo -H -u loungeadmin bash -c "thelounge add $thelounge_USER"

# check if the lounge is listening on default port 9000
# WARN if not listening on 9000
check_IS_LISTENING_DEFAULT_PORT=$(netstat -l | grep "9000" ; echo $?)
if [ $check_IS_LISTENING_DEFAULT_PORT = "0" ]; then
echo "The Lounge IRC Client is listening on the default port: 9000"
echo "Navigate to https://server-ip:9000/ to login"
elif [ $check_IS_LISTENING_DEFAULT_PORT != "0" ]; then
echo "The Lounge was not found to be listening on the default port: 9000"
fi

# Show useful commands for administration & exit
clear
echo "
>>             ~~~~!!NOTICE!!~~~~
    Please note, all configuration should be done 
    as the user: loungeadmin
              
    Either by changint to user:

        $ su - loungeadmin

    Or by running via: 

        $ sudo -H -u loungeadmin bash -c 'thelounge [command]'

    To edit the config file: 

        $ vim ~/.lounge/config.js 

    Some useful commands include: 
        thelounge -h
        thelounge --help

    Start/Status/Restart commands
        thelounge start
        thelounge status
        thelounge restart

    User Management: 
        thelounge add ramong
        thelounge edit ramong
        thelounge del ramong
"

echo "
Thank you for installing, The Lounge via CCIO Utils.
Check The Lounge status with '$ thelounge status'

If it is running you should be ready to login at:
    
    http://[YOURIP]:9000/ 
"
