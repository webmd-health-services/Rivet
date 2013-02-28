
$Connection = New-Object Data.SqlClient.SqlConnection
$PstepSchemaName = 'pstep'
$PstepMigrationsTableName = 'Migrations'
$PstepMigrationsTableFullName = '{0}.{1}' -f $PstepSchemaName,$PstepMigrationsTableName

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-Pstep' } |
    ForEach-Object { . $_.FullName }
    
Export-ModuleMember -Function Invoke-Pstep
