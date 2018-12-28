#!/bin/bash
# This script Setup Fail2Ban and UFW (Firewall)
#
# Credit:
# https://www.digitalocean.com/community/tutorials/how-to-protect-an-nginx-server-with-fail2ban-on-ubuntu-14-04
# https://www.tricksofthetrades.net/2018/05/18/fail2ban-installing-bionic/
# https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-14-04
#
clear
echo "Please provide destination email for Fail2Ban Notification"
read -p "Enter destination email, then press [ENTER] : " DEST_EMAIL
echo "Please provide sender email for Fail2Ban Notification"
read -p "Enter sender email, then press [ENTER] : " ORG_EMAIL
clear
echo "Setting up Fail2Ban, Sendmail and iptables"
sudo apt-get update -y
sudo apt-get install -y sendmail iptables-persistent
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
sudo iptables -A INPUT -j DROP
sudo dpkg-reconfigure iptables-persistent -u

## Install Fail2Ban
sudo apt-get install fail2ban -y
wget https://raw.githubusercontent.com/ridgegate/Ubuntu18.04-LEMP-Mariadb-Wordpress-bashscript/master/f2b-conf/jail.local
mv ./jail.local /etc/fail2ban/jail.local
## Configure Filters and Jails
perl -pi -e "s/f2bdestinationemail/$DEST_EMAIL/g;" /etc/fail2ban/jail.local
perl -pi -e "s/f2bsenderemail/$ORG_EMAIL/g;" /etc/fail2ban/jail.local
wget https://raw.githubusercontent.com/ridgegate/Ubuntu18.04-LEMariaDBP-Wordpress-SSL-script/master/f2b-conf/nginx-http-auth.conf
wget https://raw.githubusercontent.com/ridgegate/Ubuntu18.04-LEMariaDBP-Wordpress-SSL-script/master/f2b-conf/nginx-noscript.conf
wget https://github.com/ridgegate/Ubuntu18.04-LEMariaDBP-Wordpress-SSL-script/blob/master/f2b-conf/wordpress.conf
wget https://github.com/ridgegate/Ubuntu18.04-LEMariaDBP-Wordpress-SSL-script/blob/master/f2b-conf/nginx-req-limit.conf
mv ./nginx-http-auth.conf /etc/fail2ban/filter.d/nginx-http-auth.conf
mv ./nginx-noscript.conf /etc/fail2ban/filter.d/nginx-noscript.conf
mv ./wordpress.conf /etc/fail2ban/filter.d/wordpress.conf
mv ./nginx-req-limit.conf /etc/fail2ban/filter.d/nginx-req-limit.conf
sudo cp /etc/fail2ban/filter.d/apache-badbots.conf /etc/fail2ban/filter.d/nginx-badbots.conf #enable bad-bots
sudo systemctl service enable fail2ban
sudo systemctl service start fail2ban
echo "Done Fail2Ban"
read -t 2
clear
#
echo "Setting up firewall"
read -t 2
#Reset UFW and enable UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'
sudo ufw enable
echo
echo
echo "Done"
