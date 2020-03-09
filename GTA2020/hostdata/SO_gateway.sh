#!/bin/bash

## Set password for so user
echo "so:$sopass" | chpasswd

## Clean up routing
rm /etc/network/interfaces.d/50-cloud-init.cfg
/bin/cat <<__EOF__ >/etc/network/interfaces
auto lo
iface lo inet loopback
auto ens3
iface ens3 inet static
address 207.255.255.254
netmask 255.255.255.0
auto ens4
iface ens4 inet static
address 10.221.0.254
netmask 255.255.255.0
auto ens5
iface ens5 inet static
address 10.222.0.254
netmask 255.255.255.0
auto ens6
iface ens6 inet static
address 10.223.0.254
netmask 255.255.255.0
auto ens7
iface ens7 inet dhcp
__EOF__
for num in {3..6};do dhclient -r ens$num ; ifdown ens$num ; ip route delete default dev ens$num ; ifup ens$num;done
##restart networking
systemctl restart networking

## Allow forwarding
sysctl -w net.ipv4.ip_forward=1
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf

## adjust threshold to avoid softlocks for ancient kernel
sysctl -w kernel.watchdog_thresh=20
echo kernel.watchdog_thresh=20 >> /etc/sysctl.conf

## NAT Stuff
## By default, only allow communication out of gateway - no inter-net comms
iptables -t nat -A POSTROUTING -o ens7 -j MASQUERADE
for num in {3..6}
do
iptables -A FORWARD -i ens7 -o ens$num -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ens$num -o ens7 -j ACCEPT
done

## Allow red net to DMZ
iptables -A FORWARD -p icmp -i ens3 -o ens5 -j ACCEPT
iptables -A FORWARD -p icmp -i ens5 -o ens3 -j ACCEPT
iptables -A FORWARD -p tcp -m multiport --dport 20,21,22,80 -i ens3 -o ens5 -j ACCEPT
iptables -A FORWARD -p tcp -i ens5 -o ens3 -m state --state RELATED,ESTABLISHED -j ACCEPT

## Allow red to smb share
iptables -A FORWARD -p tcp --dport 445 -i ens3 -o ens4 -j ACCEPT
iptables -A FORWARD -p tcp -i ens4 -o ens3 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 445 -i ens3 -o ens4 -j ACCEPT
iptables -A FORWARD -p tcp -i ens4 -o ens3 -m state --state RELATED,ESTABLISHED -j ACCEPT

## Allow SSH between dmz & blue net
iptables -A FORWARD -p tcp --dport ssh -i ens6 -o ens5 -m state --state RELATED,ESTABLISHED -j ACCEPT

## Allow blue net to DMZ + Enterprise
for num in {4..5}
do
iptables -A FORWARD -i ens6 -o ens$num -j ACCEPT
iptables -A FORWARD -i ens$num -o ens6 -m state --state RELATED,ESTABLISHED -j ACCEPT
done
## Enterprise to blue net for RDP _ ossec/Wazuh
iptables -A FORWARD -p tcp --dport 3389 -i ens6 -o ens4 -j ACCEPT
iptables -A FORWARD -i ens4 -o ens6 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --dport 3389 -i ens4 -o ens6 -j ACCEPT
iptables -A FORWARD -i ens6 -o ens4 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p udp -m multiport --dport 1514,1515 -i ens4 -o ens6 -j ACCEPT
iptables -A FORWARD -p udp -m multiport --dport 1514,1515 -i ens6 -o ens4 -j ACCEPT

iptables-save > /etc/iptables.rules

## install iptables-persistent
apt-get update
apt-get install -y iptables-persistent
dpkg-reconfigure iptables-persistent -p critical

## Resolve hostname
echo -n "127.0.1.2 " >> /etc/hosts
echo $(hostname) >> /etc/hosts

## Configure ssh and sshd
echo StrictHostKeyChecking no >> /etc/ssh/ssh_config
mkdir -p /root/.ssh
touch /root/.ssh/id_rsa
cat > "/root/.ssh/id_rsa" << __EOF__
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAvm+2arR3Qeqs6sG0CdeVd5e6eELzpFnOSZGXlZhKsjlGOK79
plGlO3XNSLkRjg+1VhgAtFQ4wGf7Df2D9M1ykyUUCC6MSbVP0/bgbzi8D3sX7nGj
rOO+PPplDoFnKcFFV8YOwqhwNB4OD/6M5AqhPDgQo24ACiN1DCfeiyVtiuBOI7sC
uuXLVeElPibWMnD6REVwQks95eH4yXWTqiENnUa7mKduY1hj73eV93UdQLNLKkcx
Ab7zwDz4P1jODeCJX2jhBpHSw4yIj+ynTcAzI+K2RJ92cv0VpKcCaNVoxiure3Df
oyWqiJAQ26D6hoH7U9oXP0LRUQet4LlC+R5XpwIDAQABAoIBAF1zNHDoXh1aq8AH
jfHGePJW4ophUG42I6S2bUxbj0wmDu+B77bOGeczx6kIKDUuQC4fWTkkmzTP0cLr
xPU8XB0Y9NuO/AivkJzTaQ8rKB3wqa241jjhCVmjBjQ4DAfRb9XCuzuKrITmur/e
igTdsoF6ga+xKxPOkoGEjxB5LWgYEVP279VP8G2JTK8TKYBSZZ3YSNSbV/ELhCuJ
POTepjzyCJdsvLTBcJm1qe0A5UrUgIi4e/jjz9gEe6Ntp9JGaD7gBUoYl1kw/9iA
9QDok40xgib754SdsLd0c3+hlEDQqhlC/mZrq4P+6q4jT1DjDWvGkV3NYc+KVUc1
WM9GpQECgYEA5wQkF66mj42BiKxNLu4hzVVxo4BDeQ0x4sXbv9JL1qi00k429aDi
xFVbXkngeXPhM0YbXa215jZbCB2P+wIyYV31Vr64Z7/f9Q5Zlzj/dfWEtFFFXIh9
WENrfv+okSAinyoCOu+4tHFg9m0FXyQM0TxPXQdZ1xCwHQ6Q+amhj5UCgYEA0wgW
wrQdDfO6FeFTeMBkx61hHq1dQdGHKTCUqncSg+rzrqDgZB1pWpwZIcAW6gLfP6aV
Pq86p65mv6vFrZn1hfUonhGcBHkJWh34Vh2wBNc15LeBuR2oU4ADYuaWZUHjhDcX
Vq3/CA0qp/S8vd3ajxms4iz3gAHWYY6R/2cua0sCgYBoTOlSu+q9g2EJaOmMF72x
LDObYyyTec6dGUHG0FanOxIwpVmQ+quHgxY2ctpjW1tAwBVY7TXkE4R0HIzGAk7m
wPokyQUO6oVd6bWvXe+QvWHF26+aQJF/CSl+dEUSCNU40UmifFsDNPFXMQ+szeTv
jvAyC0CXphQtekcgQWMNJQKBgBvgOKl1g1UBefZD8nPD7kwWEfssaWI1XEZLnYe6
/N4iHhhWNe3jmLQYZJV5u00kHftZdON34CagOgBdn1okOTN9w+TFbLeGiX628MPn
XgX1q6/PsboTOdX11fytevZbMsOXR2TyzPpySs0u3fOyp5k5igXCbNsi4v+2BoEX
TyFrAoGAdetDm9cGN9kZRq8trS9AuM/U/yNqbUIxQpEuPtnQJIlEKc1CiROrvOZc
VOBVsCb6yYKfnEgnJoSwFlmkXIFIi+lxVsbLCS4ruddqbhQ5VhpfsoXqr6LtSML7
4BBJmfU9WoT6b7EFXCA1XPwbPQH7DJh3TKPUtcY+z3Y5C/2vFlI=
-----END RSA PRIVATE KEY-----
__EOF__
chmod 600 /root/.ssh/id_rsa

## update so
echo 'Acquire::http::proxy "http://cache.internal.georgiacyber.org:3142";' > /etc/apt/apt.conf.d/02proxy
sed -i 's/\$REBOOT == "yes"/\$REBOOT == "skipmeplease"/' /usr/sbin/soup
soup -y

## Signal that gateway networking is complete
$signal_gateway_networking_complete


## write sosetup file for establishment of heavy node
cat > "/root/sosetup.conf" << __EOF__
# ANSWERFILE generated by sosetup -w option
# Generation date: Sun Oct 13 18:58:14 EDT 2019
# Generated on host so-gateway
#
# These fields were computed automatically
#IP=172.17.0.1
#CORES=4
#ALL_INTERFACES=ens3 ens4 ens5 ens6 ens7
#NUM_INTERFACES=5
#
# This field is specific to reading an answer file
SNIFFING_INTERFACES='ens3 ens4 ens5 ens6 ens7'
#
# These fields were generated from your answers
SERVER=0
SERVERNAME=$so_master_address
SSH_USERNAME='so'
SGUIL_SERVER_NAME=securityonion
SGUIL_CLIENT_USERNAME=''
SGUIL_CLIENT_PASSWORD_1=''
XPLICO_ENABLED=no
OSSEC_AGENT_ENABLED=yes
OSSEC_AGENT_LEVEL=5
SALT=yes
SENSOR=1
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
IDS_ENGINE=snort
IDS_LB_PROCS=1
BRO_LB_PROCS=1
EXTRACT_FILES=yes
PCAP_SIZE=150
PCAP_RING_SIZE=64
PCAP_OPTIONS=''
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

## disable the internal firewall
ufw disable
## wait until nc exits, then run setup
nc -l 12345 -q 10
sosetup -yf /root/sosetup.conf
ufw disable
mkdir /TRA_Pcaps
wget https://github.com/GA-CyberWorkforceAcademy/metaTest/raw/master/pcaps/EK1.pcap -O /TRA_Pcaps/EK1.pcap
wget https://github.com/GA-CyberWorkforceAcademy/metaTest/raw/master/pcaps/EK2.pcap -O /TRA_Pcaps/EK2.pcap
wget https://github.com/GA-CyberWorkforceAcademy/metaTest/raw/master/pcaps/EK3.pcap -O /TRA_Pcaps/EK3.pcap
wget https://github.com/GA-CyberWorkforceAcademy/metaTest/raw/master/pcaps/OPT1.pcap -O /TRA_Pcaps/OPT1.pcap
wget https://github.com/GA-CyberWorkforceAcademy/metaTest/raw/master/pcaps/OPT2.zip -O /TRA_Pcaps/OPT2.zip
## Signal that gateway final is complete
$signal_gateway_final_complete
