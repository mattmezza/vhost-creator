#!/bin/bash

OLD=`pwd`
mkdir ~/scripts && cd $_
wget https://raw.githubusercontent.com/mattmezza/vhost-creator/master/vhost-creator.sh
chmod +x vhost-creator.sh
echo 'Installed successfully in `pwd`'
cd $OLD