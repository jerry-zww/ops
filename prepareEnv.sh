#!/bin/bash

#Download Docker
curl -sSL https://get.docker.com/ | sh

yum install -y docker-ce

#Install Docker Service & Start
systemctl enable docker
systemctl start docker

#Add composer user and setup permissions
adduser composer

usermod -aG docker composer

setfacl -m user:composer:rw /var/run/docker.sock

cd /etc/sudoers.d/
touch user-composer
echo 'composer ALL=(ALL) NOPASSWD:ALL' > user-composer

#Install nvm and nodejs
su composer

cd ~
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.30.2/install.sh | bash

source ~/.bashrc

nvm install v8.11.4

nvm alias default v8.11.4
