Param([Switch]$whatif)

$parameterFiles = Get-ChildItem *.parameters.json

foreach ($file in $parameterFiles) {
    <# testcode
    $file = $parameterFiles[0]
    #>

    write-host "##[section] Processing $($file.name)" -ForegroundColor Green

    $parameters = Get-Content -Raw -Path $file | ConvertFrom-Json

    if ($whatif) {
        Write-Host "##[section] Running What-If"
        New-AzManagementGroupDeployment `
            -Name (New-Guid).Guid `
            -Location uksouth `
            -ManagementGroupId $parameters.parameters.parTopLevelManagementGroupID.value `
            -TemplateFile "$($env:COMPONENTNAME).bicep" `
            -TemplateParameterFile $file.Name `
            -Verbose -WhatIf
    }
    if (!$whatif) {
        Write-Host "##[section] Running Deployment"
        New-AzManagementGroupDeployment `
            -Name (New-Guid).Guid `
            -Location uksouth `
            -ManagementGroupId $parameters.parameters.parTopLevelManagementGroupID.value `
            -TemplateFile "$($env:COMPONENTNAME).bicep" `
            -TemplateParameterFile $file.Name `
            -Verbose
    }
}
