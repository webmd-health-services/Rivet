
$Connection = New-Object Data.SqlClient.SqlConnection
$Connection | 
    Add-Member -MemberType NoteProperty -Name ScriptsPath -Value $null
    
$RivetSchemaName = 'pstep'
$RivetMigrationsTableName = 'Migrations'
$RivetMigrationsTableFullName = '{0}.{1}' -f $RivetSchemaName,$RivetMigrationsTableName

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-Rivet' } |
    ForEach-Object { . $_.FullName }
    
$functionsToExport = @(
                        'Add-Column',
                        'Add-Description',
                        'Add-Table',
                        'Invoke-Query',
                        'Invoke-Rivet',
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
