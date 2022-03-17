#!/bin/bash

# allow linuix access by password 
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo "ubuntu:${var.aviatrix_password}" | /usr/sbin/chpasswd
sudo adduser --disabled-password --gecos "" student
sudo echo "student:${var.aviatrix_password}" | sudo /usr/sbin/chpasswd
sudo usermod -aG sudo student
sudo /etc/init.d/ssh restart
