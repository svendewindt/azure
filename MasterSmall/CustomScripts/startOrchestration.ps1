<# Custom Script for Windows #>
param(
        [parameter(mandatory)][String]$RDSBroker,
        [parameter(mandatory)][String]$RDSWebAccess,
        [parameter(mandatory)][String]$RDSHost
    )

    ##############
    #Testing
    Set-StrictMode -Version 3.0
    $testLog = "c:\azureTestLog.log"

    New-Item -Path $testLog -ItemType file
Add-Content -Path $testLog -Value "Starting session."
Add-Content -Path $testLog -Value "$($RDSBroker)"
Add-Content -Path $testLog -Value "$($RDSWebAccess)"
Add-Content -Path $testLog -Value "$($RDSHost)"
    ##############

    #Getting required modules/scripts
    #Get Logging.psm1 in the modules folder
    $source = "https://raw.githubusercontent.com/svendewindt/azure/master/MasterSmall/CustomScripts/Logging.psm1"
    $destination = "C:\Program Files\WindowsPowerShell\Modules"
    $folderName = "Logging"

Add-Content -Path $testLog -Value "Creating folder:"
    #Create folder in the modules folder
    $output = New-Item -Path $destination -Name $folderName -ItemType directory 2>&1
Add-Content -Path $testLog -Value "Output new-item $($output)"
    #Download the logging module
    
Add-Content -Path $testLog -Value "Downloading loggingmodule..."
Add-Content -Path $testLog -Value "Source: $($source)"
Add-Content -Path $testLog -Value "Destination: $($destination)"


   $output = Invoke-WebRequest -Uri $source -OutFile "$($destination)\$($folderName)\Logging.psm1" 2>&1 
Add-Content -Path $testLog -Value "Output invoke-webrequest $($output)"
    $output = Import-module Logging.psm1  2>&1
Add-Content -Path $testLog -Value "Output import-module $($output)"
	#Logging functions can be used now.

    #Creating Installer user
    $username = "Installer"
    $securePassword = ConvertTo-SecureString "Enter123" -AsPlainText -Force 
    New-ADUser -Name $username -SamAccountName $username -UserPrincipalName $username -AccountPassword $securePassword -Enabled $true
    Add-ADGroupMember "domain admins" -Members $username 
    
    #Get DeployRDS.ps1
    $source = "https://raw.githubusercontent.com/svendewindt/azure/master/MasterSmall/CustomScripts/DeployRDS.ps1"
    $destination = $PSScriptRoot
    $deployRDSScript = "$($PSScriptRoot)\deployRDS.ps1"
    Invoke-WebRequest -Uri $source -OutFile "$deployRDSScript"

   
    $log = "c:\azureSetup.log"
    new-logFile -log $log

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
    $credential = New-Object System.Management.Automation.PSCredential ("$domainName\$($userName)",$securePassword)
    
    Write-Host "Script to run: $($deployRDSScript)"
    Invoke-Command -FilePath $deployRDSScript -ComputerName $fqdnRDSBroker -Credential $credential -ArgumentList $fqdnRDSBroker, $fqdnRDSWebAccess, $fqdnRDSHost, $log


    #.\1.ps1 -RDSBroker g1dc01 -RDSWebAccess g1rdswa01 -RDSHost g1rds01

