<# Custom Script for Windows #>




param(
        [parameter(mandatory)][String]$RDSBroker,
        [parameter(mandatory)][String]$RDSWebAccess,
        [parameter(mandatory)][String]$RDSHost
    )

    #$VerbosePreference = "Continue"

function new-logFile{
param(
    [parameter(mandatory)][String]$log
)
    if (Test-Path $log){
        Remove-Item $log -Force
    }
    New-Item -Path $log -ItemType file
}

function write-log{
param(
    #[String]$log = "c:\azureSetup.log",
    [String]$line,
    [String]$title
)
    $time = Get-Date
    if ($line){
        Add-Content -Path $log -Value "$($time) - $($line)"
    }

    if ($title){
        Add-Content -Path $log -Value ""
        Add-Content -Path $log -Value "$($time) ***** $($title) *****"
    }
    
}
    
    $log = "c:\azureSetup.log"
    new-logFile -log $log

    $fqdnRDSLicensing = [System.Net.Dns]::GetHostByName($RDSLicensing).hostname
    $fqdnRDSBroker = [System.Net.Dns]::GetHostByName($RDSBroker).hostname
    $fqdnRDSWebAccess = [System.Net.Dns]::GetHostByName($RDSWebAccess).hostname
    $fqdnRDSHost = [System.Net.Dns]::GetHostByName($RDSHost).hostname

    write-log -title "Starting Orchestration"
    write-log -line "Variables used:"

    write-log -line "FQDN Broker     : $($fqdnRDSBroker)"
    write-log -line "FQDN WebAccess  : $($fqdnRDSWebAccess)"
    write-log -line "FQDN RDS        : $($fqdnRDSHost)"

    write-log -title "Sleeping for 5 minutes to let all servers boot..."
    Start-Sleep -Seconds 300
    
    write-log -title "Setting up SessionDeployment"
    $output = New-RDSessionDeployment -ConnectionBroker $fqdnRDSBroker -WebAccessServer $fqdnRDSWebAccess -SessionHost $fqdnRDSHost 2>&1
    write-log -line $output

    write-log -title "Adding License server"
    $output = Add-RDServer -Server $fqdnRDSBroker -Role RDS-LICENSING -ConnectionBroker $fqdnRDSBroker 2>&1
    write-log -line $output

    write-log -title "Configuring Licensing mode per user"
    $output = Set-RDLicenseConfiguration -LicenseServer $fqdnRDSBroker -Mode PerUser -ConnectionBroker $fqdnRDSBroker -Force 2>&1
    write-log -line $output

