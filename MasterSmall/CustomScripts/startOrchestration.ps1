<# Custom Script for Windows #>
param(
    [parameter(mandatory)][String]$WindowsFeature
)

install-windowsfeature $WindowsFeature