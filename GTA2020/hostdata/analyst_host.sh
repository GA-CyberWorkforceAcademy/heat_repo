#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
ipaddr=$(hostname -I)
iparray=($ipaddr)
cat > "/etc/network/interfaces" << __EOF__
auto lo
allow-hotplug ens3
iface ens3 inet static
address ${iparray[0]}
netmask 255.255.0.0
gateway 10.101.255.254
dns-nameservers 10.101.255.254

allow-hotplug ens4
iface ens4 inet static
address ${iparray[1]}
netmask 255.255.255.0
dns-nameservers 10.101.255.254
up route add -net 10.192.0.0 netmask 255.192.0.0 gw 10.223.0.254 dev ens4
__EOF__
echo 'Acquire::http::proxy "http://cache.internal.georgiacyber.org:3142";' > /etc/apt/apt.conf.d/02proxy
echo 127.0.0.1 $(hostname) >> /etc/hosts
echo 10.223.0.250 SO.internal >> /etc/hosts
echo 10.222.0.15 home.gmips.gov >> /etc/hosts
echo 202.10.153.4 pwned_you_good.net >> /etc/hosts
apt-get -y update && apt-get install -y gtk2.0 build-essential git wireshark nmap xrdp
git clone https://github.com/vanhauser-thc/thc-hydra.git && cd thc-hydra && ./configure && make install
#---CREATE CLIENT USER
useradd analyst -m -U -s /bin/bash; usermod -aG sudo analyst
echo 'root:gmips123' | chpasswd; echo 'analyst:gmips123' | chpasswd
#--STARTING SERVICES
/etc/init.d/nessusd start
cat > "/etc/polkit-1/localauthority.conf.d/02-allow-colord.conf" << __EOF__
polkit.addRule(function(action, subject) {
if ((action.id == “org.freedesktop.color-manager.create-device” || action.id == “org.freedesktop.color-manager.create-profile” || action.id == “org.freedesktop.color-manager.delete-device” || action.id == “org.freedesktop.color-manager.delete-profile” || action.id == “org.freedesktop.color-manager.modify-device” || action.id == “org.freedesktop.color-manager.modify-profile”) && subject.isInGroup(“{group}”))
{
return polkit.Result.YES;
}
});
__EOF__
systemctl enable xrdp
## ALLOW RDP IN
iptables -A INPUT -p tcp --dport 3389 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3389 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables-save > /etc/iptables.rules
reboot
