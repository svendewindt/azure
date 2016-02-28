<# Custom Script for Windows #>
param(
        [parameter(mandatory)][String]$RDSBroker,
        [parameter(mandatory)][String]$RDSWebAccess,
        [parameter(mandatory)][String]$RDSHost,
        [parameter(mandatory)][String]$userName,
        [parameter(mandatory)][SecureString]$password
    )

    #Getting required modules/scripts
    #Get Logging.psm1 in the modules folder
    $source = "https://raw.githubusercontent.com/svendewindt/azure/master/MasterSmall/CustomScripts/Logging.psm1"
    $destination = "C:\Program Files\WindowsPowerShell\Modules"
    $folderName = "Logging"
    #Create folder in the modules folder
    New-Item -Path $destination -Name $folderName -ItemType directory
    #Download the logging module
    Invoke-WebRequest -Uri $source -OutFile "$($destination)\$($folderName)\Logging.psm1" 
    Import-module Logging.psm1
	#Logging functions can be used now.
    
    #Get DeployRDS.ps1
    $source = "https://raw.githubusercontent.com/svendewindt/azure/master/MasterSmall/CustomScripts/DeployRDS.ps1"
    $destination = $PSScriptRoot
    $deployRDSScript = "$($PSScriptRoot)\deployRDS.ps1"
    Invoke-WebRequest -Uri $source -OutFile "$deployRDSScript"

   
    $log = "c:\azureSetup.log"
    new-logFile -log $log

    $fqdnRDSLicensing = [System.Net.Dns]::GetHostByName($RDSLicensing).hostname
    $fqdnRDSBroker = [System.Net.Dns]::GetHostByName($RDSBroker).hostname
    $fqdnRDSWebAccess = [System.Net.Dns]::GetHostByName($RDSWebAccess).hostname
    $fqdnRDSHost = [System.Net.Dns]::GetHostByName($RDSHost).hostname
    
    write-log -log $log -title "Starting Orchestration"
    write-log -log $log -line "Variables used:"

    write-log -log $log -line "FQDN Broker         : $($fqdnRDSBroker)"
    write-log -log $log -line "FQDN WebAccess      : $($fqdnRDSWebAccess)"
    write-log -log $log -line "FQDN RDS            : $($fqdnRDSHost)"
    
    $domainName = (gwmi WIN32_ComputerSystem).domain
    write-log -log $log -line "Domainname\username : $($domainName)\$($userName)"
    #$securePassword = ConvertTo-SecureString $password -AsPlainText -Force 
    $securePassword = $password
    $credential = New-Object System.Management.Automation.PSCredential ("$domainName\$($userName)",$securePassword)

    
    Write-Host "Script to run: $($deployRDSScript)"
    Invoke-Command -FilePath $deployRDSScript -ComputerName $fqdnRDSBroker -Credential $credential -ArgumentList $fqdnRDSBroker, $fqdnRDSWebAccess, $fqdnRDSHost, $log


    #.\1.ps1 -RDSBroker g1dc01 -RDSWebAccess g1rdswa01 -RDSHost g1rds01 -userName "adminsvdw" -password "Enter123"






    