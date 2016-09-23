Configuration configureSQL
{

    param(
        [String]$nodeName = "localhost",

    )

    Import-DscResource -moduleName cdisk, xdisk, PSDesiredStateConfiguration, xComputerManagement, xPendingReboot

    Node $nodeName{

        xPendingReboot checkReboot{
            name = "CheckReboot"
        }

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        xWaitforDisk Disk2{
            DiskNumber = 2
            RetryIntervalSec = 5
            RetryCount = 30
        }

        cDiskNoRestart FData{
            DiskNumber = 2
            DriveLetter = 'F'
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