#ps1_sysnative
## For the retry loops to work, ErrorActionPreference *must* be set to Stop
$ErrorActionPreference = 'Stop'

## if the domain has not been created, run this section.  Otherwise, skip to user creation
if (!(Test-Path domain_done)) {
secedit /export /cfg c:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
rm -force c:\secpol.cfg -confirm:$false
netsh advfirewall set allprofiles state off
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
$user = [ADSI]'WinNT://./Administrator'
$user.SetPassword('safe_mode_administrator_password')
Import-Module ADDSDeployment
$safeModePwd = (ConvertTo-SecureString 'safe_mode_administrator_password' -AsPlainText -Force)
Install-ADDSForest -DomainName 'domain_name' -DomainNetbiosName 'domain_netbios_name' -SafeModeAdministratorPassword $safeModePwd -InstallDns -NoRebootOnCompletion -Force
New-Item -ItemType file domain_done
exit 1003
}

## Reach this section after domain has been created, but before the upstream DNS forward has been set or the waitcondition has been fired
## if users have been created, skip to GPO creation
## DNS needs to be very, very carefully configured and adjusted as the script executes.  How windows decides which DNS server to use on which occasion it will
## flush the cache and retry is unclear, so there should only ever be one DNS server configured:
## Set green net to point at DC for all DNS.  Until the DC is done, there is effectively no resolution available on green net
## After directory is installed, but BEFORE waitcondition is fired, set the forwarder to the public gateway.  That way, hosts trying to join will be able to do
## so without getting NXDOMAIN from the public forwarder.  They should never try and reach the forwarder on their own, or they run the risk of caching bad data
if (!(Test-Path users_done)) {
Set-DnsServerForwarder -IPAddress "10.101.255.254" -PassThru
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11"
Invoke-WebRequest -Method POST -Headers @{"X-Auth-Token" = "$xauthtoken" ; "Content-Type" = "application/json" ; "Accept" = "application/json"} -Uri $endpoint -UseBasicParsing
$password = (ConvertTo-SecureString 'safe_mode_administrator_password' -AsPlainText -Force)
$cred = New-Object System.Management.Automation.PSCredential ("domain_name\administrator", $password)
Import-Module ActiveDirectory

## First boot of new DC takes awhile.. try until success for up to 10 minutes.
## To create random strings, user this:
## cat names | while read name;do echo "New-ADUser -Credential \$cred -Server internal.gmips.gov -Name \""$name"\" -GivenName \""$(echo $name | awk '{ print $1 }')"\"        \
## -Surname \""$(echo $name | awk '{ print $2 }')"\" -SamAccountName \""$(echo $name | awk '{ print $1 }').$(echo $name | awk '{ print $2 }')"\" -UserPrincipalName         \
## \""$(echo $name | awk '{ print $1 }').$(echo $name | awk '{ print $2 }')@gmips.gov"\" -AccountPassword (ConvertTo-SecureString \""$(head /dev/urandom | tr -dc A-Za-z0-9   \
## | head -c 5 ; echo '')"\" -AsPlainText -force) -Enabled \$true"; done
$break = $false
[int]$attempt = "0"
do {
  try {
    New-ADUser -Credential $cred -Server domain_name -Name "Adam Garrett" -GivenName "Adam" -Surname "Garrett" -SamAccountName "Adam.Garrett" -UserPrincipalName "Adam.Garrett@gmips.gov" -AccountPassword (ConvertTo-SecureString "CphTH" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Darrell Wells" -GivenName "Darrell" -Surname "Wells" -SamAccountName "Darrell.Wells" -UserPrincipalName "Darrell.Wells@gmips.gov" -AccountPassword (ConvertTo-SecureString "poki5" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Dennis Bishop" -GivenName "Dennis" -Surname "Bishop" -SamAccountName "Dennis.Bishop" -UserPrincipalName "Dennis.Bishop@gmips.gov" -AccountPassword (ConvertTo-SecureString "rS459" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Phyllis Kennedy" -GivenName "Phyllis" -Surname "Kennedy" -SamAccountName "Phyllis.Kennedy" -UserPrincipalName "Phyllis.Kennedy@gmips.gov" -AccountPassword (ConvertTo-SecureString "ISSuN" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Stephanie Moody" -GivenName "Stephanie" -Surname "Moody" -SamAccountName "Stephanie.Moody" -UserPrincipalName "Stephanie.Moody@gmips.gov" -AccountPassword (ConvertTo-SecureString "vKwwa" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Lorenzo Hunter" -GivenName "Lorenzo" -Surname "Hunter" -SamAccountName "Lorenzo.Hunter" -UserPrincipalName "Lorenzo.Hunter@gmips.gov" -AccountPassword (ConvertTo-SecureString "9lxqU" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Johnathan Malone" -GivenName "Johnathan" -Surname "Malone" -SamAccountName "Johnathan.Malone" -UserPrincipalName "Johnathan.Malone@gmips.gov" -AccountPassword (ConvertTo-SecureString "9xsdE" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Jackie Woods" -GivenName "Jackie" -Surname "Woods" -SamAccountName "Jackie.Woods" -UserPrincipalName "Jackie.Woods@gmips.gov" -AccountPassword (ConvertTo-SecureString "veQKR" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Krystal Thomas" -GivenName "Krystal" -Surname "Thomas" -SamAccountName "Krystal.Thomas" -UserPrincipalName "Krystal.Thomas@gmips.gov" -AccountPassword (ConvertTo-SecureString "2zf8u" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Salvatore Boone" -GivenName "Salvatore" -Surname "Boone" -SamAccountName "Salvatore.Boone" -UserPrincipalName "Salvatore.Boone@gmips.gov" -AccountPassword (ConvertTo-SecureString "5wXzK" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Willie Barnes" -GivenName "Willie" -Surname "Barnes" -SamAccountName "Willie.Barnes" -UserPrincipalName "Willie.Barnes@gmips.gov" -AccountPassword (ConvertTo-SecureString "bYibp" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Beth Carpenter" -GivenName "Beth" -Surname "Carpenter" -SamAccountName "Beth.Carpenter" -UserPrincipalName "Beth.Carpenter@gmips.gov" -AccountPassword (ConvertTo-SecureString "em2L5" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Rhonda Zimmerman" -GivenName "Rhonda" -Surname "Zimmerman" -SamAccountName "Rhonda.Zimmerman" -UserPrincipalName "Rhonda.Zimmerman@gmips.gov" -AccountPassword (ConvertTo-SecureString "pQQc8" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Keith Bass" -GivenName "Keith" -Surname "Bass" -SamAccountName "Keith.Bass" -UserPrincipalName "Keith.Bass@gmips.gov" -AccountPassword (ConvertTo-SecureString "O2y6w" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Cameron Francis" -GivenName "Cameron" -Surname "Francis" -SamAccountName "Cameron.Francis" -UserPrincipalName "Cameron.Francis@gmips.gov" -AccountPassword (ConvertTo-SecureString "lvMPn" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Calvin Lopez" -GivenName "Calvin" -Surname "Lopez" -SamAccountName "Calvin.Lopez" -UserPrincipalName "Calvin.Lopez@gmips.gov" -AccountPassword (ConvertTo-SecureString "wHmo3" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Ronnie Lowe" -GivenName "Ronnie" -Surname "Lowe" -SamAccountName "Ronnie.Lowe" -UserPrincipalName "Ronnie.Lowe@gmips.gov" -AccountPassword (ConvertTo-SecureString "HWu7i" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Cory Hernandez" -GivenName "Cory" -Surname "Hernandez" -SamAccountName "Cory.Hernandez" -UserPrincipalName "Cory.Hernandez@gmips.gov" -AccountPassword (ConvertTo-SecureString "81P0Z" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Frances Estrada" -GivenName "Frances" -Surname "Estrada" -SamAccountName "Frances.Estrada" -UserPrincipalName "Frances.Estrada@gmips.gov" -AccountPassword (ConvertTo-SecureString "ry4gy" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Jimmie Potter" -GivenName "Jimmie" -Surname "Potter" -SamAccountName "Jimmie.Potter" -UserPrincipalName "Jimmie.Potter@gmips.gov" -AccountPassword (ConvertTo-SecureString "kDeg3" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Vicky Hamilton" -GivenName "Vicky" -Surname "Hamilton" -SamAccountName "Vicky.Hamilton" -UserPrincipalName "Vicky.Hamilton@gmips.gov" -AccountPassword (ConvertTo-SecureString "BxARG" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Traci Wheeler" -GivenName "Traci" -Surname "Wheeler" -SamAccountName "Traci.Wheeler" -UserPrincipalName "Traci.Wheeler@gmips.gov" -AccountPassword (ConvertTo-SecureString "NFgaZ" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Lana Wallace" -GivenName "Lana" -Surname "Wallace" -SamAccountName "Lana.Wallace" -UserPrincipalName "Lana.Wallace@gmips.gov" -AccountPassword (ConvertTo-SecureString "WV9dl" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Vanessa Cohen" -GivenName "Vanessa" -Surname "Cohen" -SamAccountName "Vanessa.Cohen" -UserPrincipalName "Vanessa.Cohen@gmips.gov" -AccountPassword (ConvertTo-SecureString "Y7lNl" -AsPlainText -force) -Enabled $true
    New-ADUser -Credential $cred -Server domain_name -Name "Alvin Doyle" -GivenName "Alvin" -Surname "Doyle" -SamAccountName "Alvin.Doyle" -UserPrincipalName "Alvin.Doyle@gmips.gov" -AccountPassword (ConvertTo-SecureString "GPWx4" -AsPlainText -force) -Enabled $true
    $break = $true
  }
  catch {
    if ($attempt -gt 10){
      Write-Host "Could not create user on after $attempt attempts!"
      $break = $true
    }
    else {
      Write-Host "Creation of user failed... retrying"
      Start-Sleep -Seconds 60
      $attempt = $attempt + 1
    }
  }
}
While ($break -eq $false)
New-Item -ItemType file users_done
exit 1003
}

### Make GPOs
$break = $false
[int]$attempt = "0"
do {
  try {
    Set-GPRegistryValue -Server domain_name -Name "Default Domain Policy" -Key "HKLM\Software\Policies\Microsoft\Windows Defender" -ValueName DisableAntiSpyware -Type DWORD -Value 1
    Set-ADDefaultDomainPasswordPolicy -Server domain_name -Identity domain_name -ComplexityEnabled $False -ReversibleEncryptionEnabled $True -MinPasswordLength 6 -MaxPasswordAge 0
    $break = $true
  }
  catch {
    if ($attempt -gt 10){
      Write-Host "Could not create GPOs after $attempt attempts!"
      $break = $true
    }
    else {
      Write-Host "GPO create failed... retrying"
      Start-Sleep -Seconds 60
      $attempt = $attempt + 1
    }
  }
}
While ($break -eq $false)

New-Item -Path "c:\" -Name "notevil" -ItemType "directory"
New-SmbShare -Name "share" -Path "c:\notevil" -FullAccess "domain_netbios_name\domain users"