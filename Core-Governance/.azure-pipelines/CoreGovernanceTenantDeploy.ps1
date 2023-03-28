Param([Switch]$whatif)

$parameterFiles = Get-ChildItem *.parameters.json

foreach ($file in $parameterFiles) {
    <# testcode
    $file = $parameterFiles[0]
    #>

    write-host "##[section] Processing $($file.name)" -ForegroundColor Green

    if ($whatif) {
        Write-Host "##[section] Running What-If"
        New-AzTenantDeployment `
            -Name (New-Guid).Guid `
            -Location "uksouth" `
            -TemplateFile "$($env:COMPONENTNAME).bicep" `
            -TemplateParameterFile $file.Name `
            -Verbose -WhatIf
    }
    if (!$whatif) {
        Write-Host "##[section] Running Deployment"
        New-AzTenantDeployment `
            -Name (New-Guid).Guid `
            -Location "uksouth" `
            -TemplateFile "$($env:COMPONENTNAME).bicep" `
            -TemplateParameterFile $file.Name `
            -Verbose
    }
}
