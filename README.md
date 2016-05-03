vhost-creator
============

This is a useful bash script that will let you save time creating vhosts for you.

It supports both ubuntu and centos (be careful to write `ubuntu` or `centos` in lowercase).

Instructions:
- `mkdir ~/scripts && cd $_`
- `wget https://raw.githubusercontent.com/mattmezza/vhost-creator/vvhost-creator.sh`
- `chmod +x vhost-creator.sh`
- `sudo ./vhost-creator.sh`
- follow Instructions

Don't forget to add a A record from your DNS pointing to your web server IP address.

You can also mv the script to a system wide bin folder or add it to your bash profile.

The original idea was this [one](https://gist.github.com/mattmezza/2e326ba2f1352a4b42b8)


###### Thanks to:
- `alexnogard` for his original version
- [Fred Bradley](https://github.com/fredbradley) for [this](https://gist.github.com/fredbradley/296bce8eba544647f10f) gist.
