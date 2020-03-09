!/bin/bash
##-- setup users
echo "root:toor" | chpasswd
useradd Adam_Garrett -U -m -s /bin/bash
useradd Vanessa_Cohen -U -m -s /bin/bash
echo "Adam_Garrett:CphTH" | chpasswd
echo "Vanessa_Cohen:Y71N1" | chpasswd
## --allow ssh login with password based authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
service ssh restart
# --install modified metasploitable3
echo "Setup Metasploitable3"
apt-get install -y curl git cifs-utils
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
## --msf cookbook disables all non-tcp connections - disable iptables completely per request
service iptables-persistent flush
update-rc.d -f iptables-persistent remove

## --install wazuh
apt-get install curl apt-transport-https lsb-release
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/3.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
apt-get update && apt-get install wazuh-agent -y
/var/ossec/bin/agent-auth -m 10.223.0.250
## --install dnscat2 client
git clone https://github.com/iagox86/dnscat2.git
cd dnscat2/client/
make
exit 1001