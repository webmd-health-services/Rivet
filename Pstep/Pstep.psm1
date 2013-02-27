
$Connection = New-Object Data.SqlClient.SqlConnection

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-Pstep' } |
    ForEach-Object { . $_.FullName }
    
Export-ModuleMember -Function Invoke-Pstep
