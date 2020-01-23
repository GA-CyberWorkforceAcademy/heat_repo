#!/bin/bash
echo "root:toor" | chpasswd
echo "Vanessa_Cohen:Y71N1" | chpasswd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# --- install modified metasploitable3
echo "Setup Metasploitable3"
apt-get install -y curl git
git clone https://github.com/GA-CyberWorkforceAcademy/metaTest.git
curl -L https://omnitruck.chef.io/install.sh | bash -s -- -v 13.8.5
mkdir /var/chef

cat > "/metaTest/chef/cookbooks/ms3.json" << __EOF__
{
"run_list": [
"metasploitable::users",
"metasploitable::mysql",
"metasploitable::apache_continuum",
"metasploitable::apache",
"metasploitable::php_545",
"metasploitable::phpmyadmin",
"metasploitable::proftpd",
"metasploitable::docker",
"metasploitable::samba",
"metasploitable::sinatra",
"metasploitable::chatbot",
"metasploitable::payroll_app",
"metasploitable::iptables"
]
}
__EOF__
chef-solo -j /metaTest/chef/cookbooks/ms3.json --config-option cookbook_path=/metaTest/chef/cookbooks
## msf cookbook disables all non-tcp connections - disable iptables completely per request
service iptables-persistent flush
update-rc.d -f iptables-persistent remove

## install wazuh
apt-get install curl apt-transport-https lsb-release
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/3.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
apt-get update && apt-get install wazuh-agent -y
/var/ossec/bin/agent-auth -m $so_master_address
git clone https://github.com/iagox86/dnscat2.git
cd dnscat2/client/
make

$signal_ms3_complete
exit 1001