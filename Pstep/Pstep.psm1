
$Connection = New-Object Data.SqlClient.SqlConnection
$Connection | 
    Add-Member -MemberType NoteProperty -Name ScriptsPath -Value $null
    
$PstepSchemaName = 'pstep'
$PstepMigrationsTableName = 'Migrations'
$PstepMigrationsTableFullName = '{0}.{1}' -f $PstepSchemaName,$PstepMigrationsTableName

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-Pstep' } |
    ForEach-Object { . $_.FullName }
    
$functionsToExport = @(
                        'Add-Column',
                        'Add-Description',
                        'Add-Table',
                        'Invoke-Query',
                        'Invoke-Pstep',
                        'Invoke-SqlScript',
                        'New-Column',
                        'Remove-Column',
                        'Remove-Description',
                        'Remove-StoredProcedure',
                        'Remove-Table',
                        'Remove-UserDefinedFunction',
                        'Remove-View',
                        'Set-StoredProcedure',
                        'Set-UserDefinedFunction',
                        'Set-View',
                        'Update-Description'
                      )
Export-ModuleMember -Function $functionsToExport
