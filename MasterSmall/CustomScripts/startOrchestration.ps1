<# Custom Script for Windows #>
param(
        [parameter(mandatory)][String]$RDSBroker,
        [parameter(mandatory)][String]$RDSWebAccess,
        [parameter(mandatory)][String]$RDSHost
    )

    #$VerbosePreference = "Continue"

    $fqdnRDSLicensing = [System.Net.Dns]::GetHostByName($RDSLicensing).hostname
    $fqdnRDSBroker = [System.Net.Dns]::GetHostByName($RDSBroker).hostname
    $fqdnRDSWebAccess = [System.Net.Dns]::GetHostByName($RDSWebAccess).hostname
    $fqdnRDSHost = [System.Net.Dns]::GetHostByName($RDSHost).hostname

    Write-Verbose "FQDN Broker     : $($fqdnRDSBroker)"
    Write-Verbose "FQDN WebAccess  : $($fqdnRDSWebAccess)"
    Write-Verbose "FQDN RDS        : $($fqdnRDSHost)"

    Write-Verbose "Setting up SessionDeployment"
    New-RDSessionDeployment -ConnectionBroker $fqdnRDSBroker -WebAccessServer $fqdnRDSWebAccess -SessionHost $fqdnRDSHost

    Write-Verbose "Adding License server"
    Add-RDServer -Server $fqdnRDSBroker -Role RDS-LICENSING -ConnectionBroker $fqdnRDSBroker

    Write-Verbose "Configuring Licensing mode per user"
    Set-RDLicenseConfiguration -LicenseServer $fqdnRDSBroker -Mode PerUser -ConnectionBroker $fqdnRDSBroker -Force