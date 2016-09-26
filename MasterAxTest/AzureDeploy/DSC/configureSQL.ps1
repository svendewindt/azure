Configuration configureSQL
{

    param(
        [String]$nodeName = "localhost"
    )

    Import-DscResource -moduleName cdisk, xdisk, PSDesiredStateConfiguration

    Node $nodeName{


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


   


    }
 
}