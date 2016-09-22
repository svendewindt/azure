configuration configureRDS
{
    param(
        [String]$nodeName = "localhost",
        [Parameter(mandatory)][String]$domainName,
        [Parameter(mandatory)][System.Management.Automation.PSCredential]$Admincreds
        
    )

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xComputerManagement, xPendingReboot
    Node $nodeName
    {
        xPendingReboot checkReboot{
            name = "CheckReboot"
        }

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        xComputer JoinDomain
        {
            Name = $env:COMPUTERNAME
            DomainName = $domainName
            Credential = $domaincreds
        }

        WindowsFeature RDS-RD-Server
        {
            Ensure = "Present"
            Name = "RDS-RD-Server"
            DependsOn = "[xComputer]JoinDomain" 
        }

        WindowsFeature RSAT-RDS-Licensing-Diagnosis-UI
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Licensing-Diagnosis-UI"
            DependsOn = "[xComputer]JoinDomain" 
        }

        WindowsFeature desktop-experience
        {
            Ensure = "Present"
            Name = "desktop-experience"
            DependsOn = "[xComputer]JoinDomain" 
        }

                WindowsFeature RDS-Web-Access
        {
            Ensure = "Present"
            Name = "RDS-Web-Access"
        }

        WindowsFeature RDS-Gateway
        {
            Ensure = "Present"
            Name = "RDS-Gateway"
        }
        
        WindowsFeature RSAT-RDS-Gateway
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Gateway"
        }

        
    }
}