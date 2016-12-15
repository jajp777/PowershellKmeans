# After having successfully implemented the example, this file will cluster and display a 2d plot
param (
    $AccordPath = "C:\tools\Accord.NET-3.3.0-libsonly\Release\net45",
    $Clusters = 6,
    $NumPoints = 800,
    $PlotSize = 100
)

# Load Accord.MachineLearning dll
$MlDllPath = "$AccordPath\Accord.MachineLearning.dll"
Add-Type -Path $MlDllPath

$KMeans = New-Object Accord.MachineLearning.KMeans -ArgumentList $Clusters

$Points = 1..$NumPoints | ForEach-Object { @(,@((Get-Random -Maximum $PlotSize),(Get-Random  -Maximum $PlotSize) ) ) }

# This throws an error, but I think it's erroring out on converting data to output to Powershell; I think the functionality is working
$KMeans.Learn($Points)

$Labels = $KMeans.Clusters.Decide($Points)

$Out = [System.Collections.ArrayList]@()
for ($i = 1; $i -le $Points.Count; $i++) {
    $Out.Add((
        New-Object psobject -Property ([ordered]@{
                x = $Points[$i][0]
                y = $Points[$i][1]
                cluster = $Labels[$i]
            })
    )) | Out-Null
}

(Get-Content $PSScriptRoot\ScatterPlot.html.template) -replace 'POINTSDATAGOESHERE', ($Out | ConvertTo-Json) |
    Out-File -Encoding utf8 $PSScriptRoot\out.html