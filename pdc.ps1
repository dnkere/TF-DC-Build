# # --- Variables

# # Fetch user data from the instance metadata service
# $userData = Invoke-RestMethod -Uri http://169.254.169.254/latest/user-data

# # Assuming user data is a simple text containing a stage number for simplicity
# # You might need to adapt this parsing logic based on the actual format of your user data
# $stage = if ($userData -match '^stage=(\d+)$') { $matches[1] } else { 0 }



# # --- Powershell Stage Var
# [string]$stage = $args[0]

# # --- Local Password for Machine, currently also being used for DC Admin Password
# $hostname = "DC01"
# $tz = "US Eastern Standard Time"
# $local_password = "Ollion2023!!"


# # --- Setup BootStrap Tasks
# $TaskName = "BootStrap"
# $Description = "This task will bootstrap the server"
# $UserAccount = "NT AUTHORITY\SYSTEM"
# $Principal = New-ScheduledTaskPrincipal -UserID $UserAccount -LogonType ServiceAccount -RunLevel Highest
# $Trigger = New-ScheduledTaskTrigger -AtStartup

# # --- Setup Values for Forest
# $dmode = "WinThreshold"
# $fmode = "WinThreshold"
# $dnetbioname = "DCC"
# $dname = "dcc.local"
# $gpo_base = "dc=dcc,dc=local"
# $gpo_groups = "OU=Groups,DC=dcc,DC=local"
# $gpo_users = "CN=Users,DC=dcc,DC=local"
# $gpo_computers = "CN=Computers,DC=dcc,DC=local"

# # --- Setup Reverse Lookup CIDR Range
# $reverse_lookup_cidr = "192.168.56.0/24"

# # --- End Variables

# if ($stage -eq 500) {
#     Write-Output "Finished Cleaning Up"
#     Unregister-ScheduledTask -TaskName $TaskName -TaskPath "\" -Confirm:$false

#     # Shutdown /s /t 0 /c "End of Deployment"

# } switch ($stage) {
#     2 {
#         Write-Output "Executing Rename Computer Stage"
#         $Action_Argument = "Invoke-RestMethod -Uri http://169.254.169.254/latest/user-data"

#         Unregister-ScheduledTask -TaskName $TaskName -TaskPath "\" -Confirm:$false
#         $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $Action_Argument" # Specify what program to run and with its parameters
#         Register-ScheduledTask -TaskName $TaskName -Action $Action -Description $Description -Trigger $Trigger -Principal $Principal

#         Set-TimeZone -Name $tz -PassThru

#         #Rename Host
#         Rename-Computer -NewName $hostname -Force -PassThru -Restart
#     }
# } switch ($stage) {
#     3 {
#     Write-Output "Executing Setting Static IP and Local Admin Stage"
#     $Action_Argument = "Invoke-RestMethod -Uri http://169.254.169.254/latest/user-data"

#     Unregister-ScheduledTask -TaskName $TaskName -TaskPath "\" -Confirm:$false
#     $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $Action_Argument" # Specify what program to run and with its parameters
#     Register-ScheduledTask -TaskName $TaskName -Action $Action -Description $Description -Trigger $Trigger -Principal $Principal

#     #Set all NICs to static with current IP; see - https://itproguru.com/expert/2012/01/using-powershell-to-get-or-set-networkadapterconfiguration-view-and-change-network-settings-including-dhcp-dns-ip-address-and-more-dynamic-and-static-step-by-step/
#     $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername . | where{$_.IPEnabled -eq $true -and $_.DHCPEnabled -eq $true}
#     Foreach($NIC in $NICs) {
#         $ip = ($NIC.IPAddress[0])
#         $gateway = $NIC.DefaultIPGateway
#         $subnet = $NIC.IPSubnet[0]
#         $dns = $NIC.DNSServerSearchOrder
#         $NIC.EnableStatic($ip, $subnet)
#         $NIC.SetGateways($gateway)
#         $NIC.SetDNSServerSearchOrder($dns)
#         $NIC.SetDynamicDNSRegistration("FALSE")
#     }

#     #set administrator account password
#     net user administrator $local_password

#     Restart-Computer -Force
#                 }       
#     } switch ($stage) {
#         4 {
#         Write-Output "Executing Deploy Forest Stage"
#         $Action_Argument = "Invoke-RestMethod -Uri http://169.254.169.254/latest/user-data"
   
#         Unregister-ScheduledTask -TaskName $TaskName -TaskPath "\" -Confirm:$false
#         $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $Action_Argument" # Specify what program to run and with its parameters
#         Register-ScheduledTask -TaskName $TaskName -Action $Action -Description $Description -Trigger $Trigger -Principal $Principal
        
#         #Setup the server as a domain controller
#         $Password = $local_password | ConvertTo-SecureString -AsPlainText -Force

#         Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

#         Import-Module ADDSDeployment

#         Install-ADDSForest -SafeModeAdministratorPassword $Password -CreateDnsDelegation:$false -DomainMode $dmode -DomainName $dname -DomainNetbiosName $dnetbioname -ForestMode $fmode -InstallDns:$true -NoRebootOnCompletion:$false -Force:$true
#     }
#     } switch ($stage) {
#         5 {
#         Write-Output "Executing Add Reverse Lookup and Deploy GPO Stage"
#         $Action_Argument = "Invoke-RestMethod -Uri http://169.254.169.254/latest/user-data"
   
#         Unregister-ScheduledTask -TaskName $TaskName -TaskPath "\" -Confirm:$false
#         $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $Action_Argument" # Specify what program to run and with its parameters
#         Register-ScheduledTask -TaskName $TaskName -Action $Action -Description $Description -Trigger $Trigger -Principal $Principal

#         # Add Reverse Lookup - Use Get-DNSServerZone to fetch results for reverse lookup
#         Add-DnsServerPrimaryZone -NetworkID $reverse_lookup_cidr -ReplicationScope "Domain"
        
#         # Deploy GPO
#         Expand-Archive -LiteralPath 'C:\scripts\GPO.zip' -Destination 'C:\scripts\'

#         New-GPO -Name "Enable Win-RM" | New-GPLink -Target $gpo_computers
#         Import-GPO -BackupGpoName "Enable Win-RM" -Path "C:\scripts\GPO\GPO\" -TargetName "Enable Win-RM"

#         Restart-Computer -Force
#     }
#     } switch ($stage) {
#         6 {
#         Write-Output "Executing Deploy GPO Stage"
#         $Action_Argument = "Invoke-RestMethod -Uri http://169.254.169.254/latest/user-data"
   
#         Unregister-ScheduledTask -TaskName $TaskName -TaskPath "\" -Confirm:$false
#         $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $Action_Argument" # Specify what program to run and with its parameters
#         Register-ScheduledTask -TaskName $TaskName -Action $Action -Description $Description -Trigger $Trigger -Principal $Principal

#         Import-Module activedirectory
#         sleep 30
#         #convert password string to secure.string 
#         $securepassword = ConvertTo-SecureString $local_password -AsPlainText -Force

#         #Create OU -- Groups
#         New-ADOrganizationalUnit -Name "Groups" -Path $gpo_base

#         #Create linux_users, linux_admins, gitlab_users groups in AD
#         New-ADGroup -Name "linux_users" -SamAccountName linux_users -GroupCategory Security -GroupScope Global -DisplayName "Linux Users" -Path $gpo_groups -Description "Members of this group can login the on linux servers"

#         New-ADGroup -Name "linux_admins" -SamAccountName linux_admins -GroupCategory Security -GroupScope Global -DisplayName "Linux Administrators" -Path $gpo_groups -Description "Members of this group can run all the commands on linux servers and act as Administrators"

#         New-ADGroup -Name "gitlab_users" -SamAccountName gitlab_users -GroupCategory Security -GroupScope Global -DisplayName "Gitlab Users" -Path $gpo_groups -Description "Members of this group can login to a4l-git.msx.local Gitlab code repository"

#         #Create users in AD

#         New-ADUser -Name "Clark Kent" -EmailAddress "mandeepsinghlaller+superman@gmail.com"-SamAccountName "super.man" -Accountpassword $securepassword -Path $gpo_users -ChangePasswordAtLogon $False -PasswordNeverExpires $true -Enabled $true

#         New-ADUser -Name "Mandeep Singh" -EmailAddress "mandeepsinghlaller@gmail.com"-SamAccountName "mandeep.s" -Accountpassword $securepassword -Path $gpo_users -ChangePasswordAtLogon $False -PasswordNeverExpires $true -Enabled $true

#         New-ADUser -Name "Bruce Wayne" -EmailAddress "mandeepsinghlaller+batman@gmail.com" -SamAccountName "bat.man" -Accountpassword $securepassword -Path $gpo_users -ChangePasswordAtLogon $False -PasswordNeverExpires $true -Enabled $true

#         New-ADUser -Name "Peter Parker" -EmailAddress "mandeepsinghlaller+spiderman@gmail.com" -SamAccountName "spider.man" -Accountpassword $securepassword -Path $gpo_users -ChangePasswordAtLogon $False -PasswordNeverExpires $true -Enabled $true

#         New-ADUser -Name "Tony Stark" -EmailAddress "mandeepsinghlaller+ironman@gmail.com" -SamAccountName "iron.man" -Accountpassword $securepassword -Path $gpo_users -ChangePasswordAtLogon $False -PasswordNeverExpires $true -Enabled $true

#         Add-ADGroupMember -Identity linux_users -Members bat.man,mandeep.s,super.man,iron.man,spider.man
#         Add-ADGroupMember -Identity linux_admins -Members bat.man,mandeep.s
#         Add-ADGroupMember -Identity gitlab_users -Members bat.man,mandeep.s

#         Restart-Computer -Force
#     }
# }else{
#     Write-Output "Setup Automated Script"
#     $Action_Argument = "Invoke-RestMethod -Uri http://169.254.169.254/latest/user-data"

#     #Vagrant Specific
#     mkdir C:\scripts
#     Copy-Item -Path "C:\vagrant\provision\setupdc-updated001.ps1" -Destination "C:\scripts\setupdc-updated001.ps1" -Force
#     Copy-Item -Path "C:\vagrant\provision\GPO.zip" -Destination "C:\scripts\GPO.zip" -Force


#     #Setup New task
#     $Action= New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $Action_Argument" # Specify what program to run and with its parameters
#     Register-ScheduledTask -TaskName $TaskName -Action $Action -Description $Description -Trigger $Trigger -Principal $Principal

#     Restart-Computer -Force
# }
