Param([Switch]$whatif)

$parameterFiles = Get-ChildItem *.parameters.json

foreach ($file in $parameterFiles) {
    <# testcode
    $file = $parameterFiles[0]
    #>

    write-host "##[section] Processing $($file.name)" -ForegroundColor Green

    $parameters = Get-Content -Raw -Path $file | ConvertFrom-Json

    Set-AzContext -Subscription $parameters.parameters.parSubscription.value -Verbose

    if ($whatif) {
        Write-Host "##[section] Running What-If"
        New-AzResourceGroupDeployment `
            -Name (New-Guid).Guid `
            -ResourceGroupName $parameters.parameters.parResourceGroupName.value `
            -TemplateFile "$($env:COMPONENTNAME).bicep" `
            -TemplateParameterFile $file.Name `
            -Verbose -WhatIf
    }
    if (!$whatif) {
        Write-Host "##[section] Running Deployment"
        New-AzResourceGroupDeployment `
            -Name (New-Guid).Guid `
            -ResourceGroupName $parameters.parameters.parResourceGroupName.value `
            -TemplateFile "$($env:COMPONENTNAME).bicep" `
            -TemplateParameterFile $file.Name `
            -Verbose
    }
}
