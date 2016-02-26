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
    [parameter(mandatory)][String]$log,
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
