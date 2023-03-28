Param([Switch]$whatif)

$parameterFiles = Get-ChildItem *.parameters.json

foreach ($file in $parameterFiles) {


    write-host "##[section] Processing $($file.name)" -ForegroundColor Green

    $parameters = Get-Content -Raw -Path $file | ConvertFrom-Json
    $MGs = $parameters.parameters.parManagementGroupIDs.value
    Foreach ($MG in $MGs){

    if ($whatif) {
        Write-Host "##[section] Running What-If"
        New-AzManagementGroupDeployment `
            -Name (New-Guid).Guid `
            -Location uksouth `
            -ManagementGroupId $MG `
            -TemplateFile "$($env:COMPONENTNAME).bicep" `
            -TemplateParameterFile $file.Name `
            -Verbose -WhatIf
    }
    if (!$whatif) {
        Write-Host "##[section] Running Deployment"
        New-AzManagementGroupDeployment `
            -Name (New-Guid).Guid `
            -Location uksouth `
            -ManagementGroupId $MG `
            -TemplateFile "$($env:COMPONENTNAME).bicep" `
            -TemplateParameterFile $file.Name `
            -Verbose
    }
  }
}
