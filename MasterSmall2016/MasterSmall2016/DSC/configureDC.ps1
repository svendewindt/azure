
configuration configureDC{
    param(
        [String]$nodeName = "localhost",
        [Parameter(mandatory)][System.Management.Automation.PSCredential]$Admincreds,
        [Parameter(mandatory)][String]$domainName

    )

        Import-DscResource -module xNetworking, xActiveDirectory, xPendingReboot
        $Interface = Get-NetAdapter| Where Name -Like "Ethernet*" | Select-Object -First 1
        $InteraceAlias = $($Interface.Name)
        [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

        node $nodeName{
        WindowsFeature RSAT
        {
            Ensure = "present"
            Name = "RSAT-dns-server"
        }

        WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"
            IncludeAllSubFeature = $true                                                                                                                              
        }

        xDnsServerAddress DnsServerAddress 
        { 
            Address        = '127.0.0.1' 
            InterfaceAlias = $InteraceAlias
            AddressFamily  = 'IPv4'
        }

        WindowsFeature RSAT-AD
        {
            Ensure = "present"
            Name = "RSAT-AD-Tools"
            IncludeAllSubFeature = $true
        }


        WindowsFeature ActiveDirectory{
            Ensure = "Present"
            Name = "AD-Domain-Services"
            
        }

        WindowsFeature RSAT-AD-Powershell
        {
            Ensure = "present"
            Name = "RSAT-AD-Powershell"
            IncludeAllSubFeature = $true
        }

        XADDomain SetupDomain{
            DomainName = $domainName
            DomainAdministratorCredential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            dependson = '[WindowsFeature]ActiveDirectory'

        }

        xPendingReboot checkReboot{
            name = "checkReboot"
        }


        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }
    }
}

#installAD -adminUserName "AdminSVDW" -adminPassword "Enter456" -domainName "sven.local" -ConfigurationData $ConfigData
