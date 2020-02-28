#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
ifup ens3;ifup ens4;ifdown ens3;ifdown ens4;ifup ens3;ifup ens4
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
