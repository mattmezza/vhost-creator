#!/bin/bash
# This script is used for create virtual hosts on CentOs.
# Created by alexnogard from http://alexnogard.com
# Improved by mattmezza from http://matteomerola.me
# Feel free to modify it
#   PARAMETERS
#
# $usr          - User
# $dir          - directory of web files
# $servn        - webserver address without www.
# $cname        - cname of webserver
# EXAMPLE
# Web directory = /var/www/
# ServerName    = domain.com
# cname            = devel
#
#
# Check if you execute the script as root user
#
# This will check if directory already exist then create it with path : /directory/you/choose/domain.com
# Set the ownership, permissions and create a test index.php file
# Create a vhost file domain in your /etc/httpd/conf.d/ directory.
# And add the new vhost to the hosts.
#
#
if [ "$(whoami)" != 'root' ]; then
echo "Dude, you should execute this script as root user..."
exit 1;
fi

osname="ubuntu"
SERVICE_="apache2"
VHOST_PATH="/etc/apache2/sites-available"
CFG_TEST="apachectl -t"
if [ "$osname" == "centos" ]; then
  SERVICE_="httpd"
  VHOST_PATH="/etc/httpd/conf.d"
  CFG_TEST="service httpd configtest"
elif [ "$osname" != "ubuntu" ]; then
  echo "Sorry mate but I only support ubuntu or centos"
  echo " "
  echo "By the way, are you sure you have entered 'centos' or 'ubuntu' all lowercase???"
  exit 1;
fi

echo "Enter the server name you want"
read -p "e.g. mydomain.tld (without www) : " servn
cname="www"
dir="/var/www/"
docroot="public"
usr="apache/www-data"
listen="*"
port="80"

if ! mkdir -p $dir$cname_$servn/$docroot; then
echo "Web directory already Exist !"
else
echo "Web directory created with success !"
fi
echo "<h1>$cname $servn</h1>" > $dir$cname_$servn/$docroot/index.html
chown -R $usr:$usr $dir$cname_$servn/$docroot
chmod -R '775' $dir$cname_$servn/$docroot
mkdir /var/log/$cname_$servn

alias=$cname.$servn
if [[ "${cname}" == "" ]]; then
alias=$servn
fi

echo "#### $cname $servn
<VirtualHost $listen:$port>
  ServerName $servn
  ServerAlias $alias
  DocumentRoot $dir$cname_$servn/$docroot
  <Directory $dir$cname_$servn/$docroot>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted
  </Directory>
</VirtualHost>" > $VHOST_PATH/$cname_$servn.conf

if ! echo -e $VHOST_PATH/$cname_$servn.conf; then
  echo "Virtual host wasn't created !"
else
  echo "Virtual host created !"
fi

sudo a2ensite $cname_$servn.conf

sudo echo "127.0.0.1 $servn" >> /etc/hosts

if [ "$alias" != "$servn" ]; then
sudo echo "127.0.0.1 $alias" >> /etc/hosts
fi

sudo service apache2 restart

echo "======================================"
echo "All works done! You should be able to see your website at http://$servn"
echo "======================================"
echo ""
