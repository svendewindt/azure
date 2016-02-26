param(
        [parameter(mandatory)][String]$fqdnRDSBroker,
        [parameter(mandatory)][String]$fqdnRDSWebAccess,
        [parameter(mandatory)][String]$fqdnRDSHost,
        [parameter(mandatory)][String]$log
    )

function tryPsRemoting{
    param(
        [parameter(mandatory)][String]$server,
        [parameter(mandatory)][String]$log
    )

    write-log -log $log -title "Trying $($server)"
    try{
        write-log -log $log -line "New-Pssesion"
        $output = $psSession = New-PSSession -ComputerName $server 2>&1
        write-log -log $log  -line $output
        #write-host "computername: $($psSession.ComputerName)" 
        if ($psSession.ComputerName.Length -gt 0){
            write-log -log $log  -line "Enter-Pssesion"
            $output = Enter-PSSession $psSession -ErrorAction SilentlyContinue
            write-log -log $log  -line $output

            write-log -log $log  -line "Successfully logged in on $($server)"
            <#
            write-log -log $log  "Exit-PSSession"
            $output =Exit-PSSession -ErrorAction SilentlyContinue
            write-log -log $log  -line $output

            write-log -log $log  -line "Closing Pssesion"
            $output = Get-PSSession -ComputerName $server | Remove-PSSession
            write-log -log $log  -line $output
            #>
        } else {
            write-log -log $log "Unable to log on to $($server)"
        }
        
    }catch{
        write-log -log $log -line $_.exception
    }
}
    $servers = $fqdnRDSBroker, $fqdnRDSWebAccess, $fqdnRDSHost

    #testing connection to servers
    write-log -log $log -title "Trying to ps remote to the servers"
    foreach ($server in $servers){
        tryPsRemoting -server $server -log $log
    }

    #start deploying
    write-log -log $log -title "Setting up SessionDeployment"
    $output = New-RDSessionDeployment -ConnectionBroker $fqdnRDSBroker -WebAccessServer $fqdnRDSWebAccess -SessionHost $fqdnRDSHost 2>&1
    write-log -log $log -line $output

    write-log -log $log -title "Adding License server"
    $output = Add-RDServer -Server $fqdnRDSBroker -Role RDS-LICENSING -ConnectionBroker $fqdnRDSBroker 2>&1
    write-log -log $log -line $output

    write-log -log $log -title "Configuring Licensing mode per user"
    $output = Set-RDLicenseConfiguration -LicenseServer $fqdnRDSBroker -Mode PerUser -ConnectionBroker $fqdnRDSBroker -Force 2>&1
    write-log -log $log -line $output
