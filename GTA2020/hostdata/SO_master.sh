#!/bin/bash

## Set password for so user
echo "so:$sopass" | chpasswd
ipaddr=$(hostname -I)
cat > "/etc/network/interfaces" << __EOF__
auto lo
allow-hotplug ens3
iface ens3 inet static
address $ipaddr
netmask 255.255.255.0
gateway 10.223.0.254
dns-nameservers 10.101.255.254
__EOF__

## adjust threshold to avoid softlocks for ancient kernel
sysctl -w kernel.watchdog_thresh=20
echo kernel.watchdog_thresh=20 >> /etc/sysctl.conf

mkdir -p /home/so/.ssh/ && touch /home/so/.ssh/authorized_keys
cat > "/home/so/.ssh/authorized_keys" << __EOF__
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+b7ZqtHdB6qzqwbQJ15V3l7p4QvOkWc5JkZeVmEqyOUY4rv2mUaU7dc1IuRGOD7VWGAC0VDjAZ/sN/YP0zXKTJRQILoxJtU/T9uBvOLwPexfucaOs4748+mUOgWcpwUVXxg7CqHA0Hg4P/ozkCqE8OBCjbgAKI3UMJ96LJW2K4E4juwK65ctV4SU+JtYycPpERXBCSz3l4fjJdZOqIQ2dRruYp25jWGPvd5X3dR1As0sqRzEBvvPAPPg/WM4N4IlfaOEGkdLDjIiP7KdNwDMj4rZEn3Zy/RWkpwJo1WjGK6t7cN+jJaqIkBDboPqGgftT2hc/QtFRB63guUL5Hlen
__EOF__
chown -R so:so /home/so/.ssh
echo "so ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

## update so
echo 'Acquire::http::proxy "http://cache.internal.georgiacyber.org:3142";' > /etc/apt/apt.conf.d/02proxy
sed -i 's/\$REBOOT == "yes"/\$REBOOT == "skipmeplease"/' /usr/sbin/soup
soup -y

cat > "/root/sosetup.conf" << __EOF__
# ANSWERFILE generated by sosetup -w option
# Generation date: Sun Oct 13 15:26:45 EDT 2019
# Generated on host test-so-master-rq7xgvcecfct
#
# These fields were computed automatically
#IP=172.17.0.1
#CORES=4
#ALL_INTERFACES=ens3
#NUM_INTERFACES=1
#
# This field is specific to reading an answer file
SNIFFING_INTERFACES='ens3'
#
# These fields were generated from your answers
SERVER=1
SERVERNAME=localhost
SSH_USERNAME=''
SGUIL_SERVER_NAME=securityonion
SGUIL_CLIENT_USERNAME='$username'
SGUIL_CLIENT_PASSWORD_1='$userpass'
XPLICO_ENABLED=no
OSSEC_AGENT_ENABLED=yes
OSSEC_AGENT_LEVEL=5
SALT=yes
SENSOR=0
BRO_ENABLED=yes
IDS_ENGINE_ENABLED=yes
SNORT_AGENT_ENABLED=yes
BARNYARD2_ENABLED=yes
PCAP_ENABLED=yes
PCAP_AGENT_ENABLED=yes
PRADS_ENABLED=no
SANCP_AGENT_ENABLED=no
PADS_AGENT_ENABLED=no
HTTP_AGENT_ENABLED=no
ARGUS_ENABLED=no
IDS_RULESET='ETOPEN'
OINKCODE=''
PF_RING_SLOTS=4096
IDS_ENGINE=Suricata
IDS_LB_PROCS=1
BRO_LB_PROCS=1
EXTRACT_FILES=yes
PCAP_SIZE=150
PCAP_RING_SIZE=64
PCAP_OPTIONS='-c'
WARN_DISK_USAGE=80
CRIT_DISK_USAGE=90
DAYSTOKEEP=30
DAYSTOREPAIR=7
LOGSTASH_OUTPUT_REDIS=no
LOGSTASH_INPUT_REDIS=no
ELASTIC=yes
FORWARD=
LOG_SIZE_LIMIT=15000000000
__EOF__

sosetup -y -f /root/sosetup.conf
ufw disable
/var/ossec/bin/ossec-authd
wget https://raw.githubusercontent.com/GA-CyberWorkforceAcademy/metaTest/master/SO_edits/index.php -O /var/www/so/index.php
mkdir /var/www/so/Intel
wget https://raw.githubusercontent.com/GA-CyberWorkforceAcademy/metaTest/master/SO_edits/index.html -O /var/www/so/Intel/index.html
echo master_done | nc 10.223.0.254 12345
