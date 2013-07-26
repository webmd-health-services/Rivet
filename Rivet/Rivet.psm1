
$Connection = New-Object Data.SqlClient.SqlConnection
$Connection | 
    Add-Member -MemberType NoteProperty -Name ScriptsPath -Value $null
    
$RivetSchemaName = 'rivet'
$RivetMigrationsTableName = 'Migrations'
$RivetMigrationsTableFullName = '{0}.{1}' -f $RivetSchemaName,$RivetMigrationsTableName

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-Rivet' } |
    ForEach-Object { . $_.FullName }

$privateFunctions = @(
                        'Connect-Database',
                        'Convert-FromJson',
                        'Disconnect-Database',
                        'Get-RivetConfig',
                        'Initialize-Database',
                        'New-ConstraintName',
                        'New-Migration',
                        'Resolve-ObjectScriptPath',
                        'Test-Migration',
                        'Test-Schema',
                        'Test-Table',
                        'Update-Database',
                        'Write-RivetError'
                      )

$functionsToExport = Get-Command -CommandType Function -Module Rivet |
                        Where-Object { $privateFunctions -notcontains $_.Name }

Export-ModuleMember -Function $functionsToExport
