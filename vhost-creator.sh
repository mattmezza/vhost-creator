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
echo "First of all, is this server an Ubuntu or is it a CentOS?"
read -p "ubuntu or centos (lowercase, please) : " osname

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
echo "Enter a CNAME"
read -p "e.g. www or dev for dev.website.com : " cname
echo "Enter the path of directory you wanna use"
read -p "e.g. /var/www/, dont forget the / : " dir
echo "Enter the name of the document root folder"
read -p "e.g. htdocs : " docroot
echo "Enter the user you wanna use"
read -p "e.g. apache/www-data : " usr
echo "Enter the listened IP for the web server"
read -p "e.g. * : " listen
echo "Enter the port on which the web server should respond"
read -p "e.g. 80 : " port

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
echo "Would you like me to create ssl virtual host [y/n]? "
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $VHOST_PATH/$cname_$servn.key -out $VHOST_PATH/$cname_$servn.crt
if ! echo -e $VHOST_PATH/$cname_$servn.key; then
echo "Certificate key wasn't created !"
else
echo "Certificate key created !"
fi
if ! echo -e $VHOST_PATH/$cname_$servn.crt; then
echo "Certificate wasn't created !"
else
echo "Certificate created !"
if [ "$osname" == "ubuntu" ]; then
  echo "Enabling Virtual host..."
  sudo a2ensite $cname_$servn.conf
fi
fi

echo "#### ssl $cname $servn
<VirtualHost $listen:443>
SSLEngine on
SSLCertificateFile $VHOST_PATH/$cname_$servn.crt
SSLCertificateKeyFile $VHOST_PATH/$cname_$servn.key
ServerName $servn
ServerAlias $alias
DocumentRoot $dir$cname_$servn/$docroot
<Directory $dir$cname_$servn/$docroot>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
Order allow,deny
Allow from all
Satisfy Any
</Directory>
</VirtualHost>" > $VHOST_PATH/ssl.$cname_$servn.conf
if ! echo -e $VHOST_PATH/ssl.$cname_$servn.conf; then
echo "SSL Virtual host wasn't created !"
else
echo "SSL Virtual host created !"
if [ "$osname" == "ubuntu" ]; then
  echo "Enabling SSL Virtual host..."
  sudo a2ensite ssl.$cname_$servn.conf
fi
fi
fi

echo "127.0.0.1 $servn" >> /etc/hosts
if [ "$alias" != "$servn" ]; then
echo "127.0.0.1 $alias" >> /etc/hosts
fi
echo "Testing configuration"
sudo $CFG_TEST
echo "Would you like me to restart the server [y/n]? "
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
service $SERVICE_ restart
fi
echo "======================================"
echo "All works done! You should be able to see your website at http://$servn"
echo ""
echo "Share the love! <3"
echo "======================================"
echo ""
echo "Wanna contribute to improve this script? Found a bug? https://github.com/mattmezza/vhost-creator"
