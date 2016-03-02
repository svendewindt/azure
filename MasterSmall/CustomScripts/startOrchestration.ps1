<# Custom Script for Windows #>
param(
        [parameter(mandatory)][String]$RDSBroker,
        [parameter(mandatory)][String]$RDSWebAccess,
        [parameter(mandatory)][String]$RDSHost
    )
    Set-StrictMode -Version 3.0
    #Getting required modules/scripts
    #Get Logging.psm1 in the modules folder
    $source = "https://raw.githubusercontent.com/svendewindt/azure/master/MasterSmall/CustomScripts/Logging.psm1"
    $destination = "C:\Program Files\WindowsPowerShell\Modules"
    $folderName = "Logging"
    #Create folder in the modules folder
    New-Item -Path $destination -Name $folderName -ItemType directory 2>&1
    #Download the logging module
    Invoke-WebRequest -Uri $source -OutFile "$($destination)\$($folderName)\Logging.psm1" 2>&1 
    Import-module Logging.psm1  2>&1
	#Logging functions can be used now.

    $fqdnRDSBroker = [System.Net.Dns]::GetHostByName($RDSBroker).hostname
    $fqdnRDSWebAccess = [System.Net.Dns]::GetHostByName($RDSWebAccess).hostname
    $fqdnRDSHost = [System.Net.Dns]::GetHostByName($RDSHost).hostname
 
	$log = "c:\azureSetup.log"
    new-logFile -log $log   
    write-log -log $log -title "Starting Orchestration"
    write-log -log $log -line "Variables used:"

    write-log -log $log -line "FQDN Broker         : $($fqdnRDSBroker)"
    write-log -log $log -line "FQDN WebAccess      : $($fqdnRDSWebAccess)"
    write-log -log $log -line "FQDN RDS            : $($fqdnRDSHost)"

    #Creating Installer user
    Write-log -log $log -title "Creating Installer user"
	$username = "Installer"
	Write-log -log $log -line "Username            : $($username)"
	#Creating Password
	[String]$guid = [System.Guid]::NewGuid()
	Write-log -log $log -line "Password            : $($guid.Substring(1,15))"
    $securePassword = ConvertTo-SecureString $($guid.Substring(1,15)) -AsPlainText -Force 
	Write-log -log $log -line "Creating user"
    New-ADUser -Name $username -SamAccountName $username -UserPrincipalName $username -AccountPassword $securePassword -Enabled $true
	Write-log -log $log -line "Adding user to group"
    Add-ADGroupMember "domain admins" -Members $username 

	Write-log -log $log -title "Creating Credentials"
    $domainName = (gwmi WIN32_ComputerSystem).domain
    write-log -log $log -line "Domainname\username : $($domainName)\$($userName)"
    $credential = New-Object System.Management.Automation.PSCredential ("$domainName\$($userName)",$securePassword)
    
    #Get DeployRDS.ps1
	$scriptName = "DeployRDS.ps1"
	Write-log -log $log -title "Downloading $($scriptName)"
    $source = "https://raw.githubusercontent.com/svendewindt/azure/master/MasterSmall/CustomScripts/$($scriptName)"
	Write-log -log $log -line "Source              : $($source)"
    $destination = $PSScriptRoot
    $deployRDSScript = "$($PSScriptRoot)\$($scriptName)"
	Write-log -log $log -line "Destination         : $($deployRDSScript)"
	Write-log -log $log -line "Downloading"
    Invoke-WebRequest -Uri $source -OutFile "$deployRDSScript"
   
	Write-log -log $log -title "Starting $($scriptName)"
    Invoke-Command -FilePath $deployRDSScript -ComputerName $fqdnRDSBroker -Credential $credential -ArgumentList $fqdnRDSBroker, $fqdnRDSWebAccess, $fqdnRDSHost, $log

	#remove Installer user.


    #.\1.ps1 -RDSBroker g1dc01 -RDSWebAccess g1rdswa01 -RDSHost g1rds01

