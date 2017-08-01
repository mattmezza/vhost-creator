#!/bin/bash

OLD=`pwd`
INSTALL_DIR=/usr/local/bin
cd $INSTALL_DIR
wget https://raw.githubusercontent.com/mattmezza/vhost-creator/master/vhost-creator.sh
mv vhost-creator.sh vhost-creator
chmod +x vhost-creator
echo "Installed successfully in $INSTALL_DIR"
cd $OLD