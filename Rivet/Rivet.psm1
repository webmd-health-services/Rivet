
$Connection = New-Object Data.SqlClient.SqlConnection
$Connection | 
    Add-Member -MemberType NoteProperty -Name ScriptsPath -Value $null

$RivetSchemaName = 'rivet'
$RivetMigrationsTableName = 'Migrations'
$RivetMigrationsTableFullName = '{0}.{1}' -f $RivetSchemaName,$RivetMigrationsTableName

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-Rivet' -and $_.BaseName -ne 'Get-Migration' -and $_.BaseName -ne 'Export-Row' } |
    ForEach-Object { . $_.FullName }

$publicFunctions = @(
                        'Add-Column',
                        'Add-DataType',
                        'Add-DefaultConstraint',
                        'Add-Description',
                        'Add-ExtendedProperty',
                        'Add-ForeignKey',
                        'Add-Index',
                        'Add-PrimaryKey',
                        'Add-Row',
                        'Add-Schema',
                        'Add-StoredProcedure',
                        'Add-Synonym',
                        'Add-Table',
                        'Add-Trigger',
                        'Add-UniqueConstraint',
                        'Add-UserDefinedFunction',
                        'Add-View',
                        'Get-Migration',
                        'Invoke-Query',
                        'Invoke-Rivet',
                        'Invoke-SqlScript',
                        'New-BigIntColumn',
                        'New-BinaryColumn',
                        'New-BitColumn',
                        'New-CharColumn',
                        'New-Column',
                        'New-DateColumn',
                        'New-DateTimeColumn',
                        'New-DateTime2Column',
                        'New-DateTimeOffsetColumn',
                        'New-DecimalColumn',
                        'New-FloatColumn',
                        'New-HierarchyIDColumn',
                        'New-IntColumn',
                        'New-MoneyColumn',
                        'New-NCharColumn',
                        'New-NumericColumn',
                        'New-NVarCharColumn',
                        'New-RealColumn',
                        'New-RowVersionColumn',
                        'New-SmallDateTimeColumn',
                        'New-SmallIntColumn',
                        'New-SmallMoneyColumn',
                        'New-SqlVariantColumn',
                        'New-StoredProcedure',
                        'New-TimeColumn',
                        'New-TinyIntColumn',
                        'New-UniqueIdentifierColumn',
                        'New-UserDefinedFunction',
                        'New-VarBinaryColumn',
                        'New-VarCharColumn',
                        'New-View',
                        'New-XmlColumn',
                        'Remove-Column',
                        'Remove-DefaultConstraint',
                        'Remove-Description',
                        'Remove-ExtendedProperty',
                        'Remove-ForeignKey',
                        'Remove-Index',
                        'Remove-PrimaryKey',
                        'Remove-Row',
                        'Remove-Schema',
                        'Remove-StoredProcedure',
                        'Remove-Synonym',
                        'Remove-Table',
                        'Remove-UniqueConstraint',
                        'Remove-UserDefinedFunction',
                        'Remove-Trigger',
                        'Remove-View',
                        'Rename-Column',
                        'Rename-Constraint',
                        'Rename-Index',
                        'Rename-Table',
                        'Set-StoredProcedure',
                        'Set-UserDefinedFunction',
                        'Set-View',
                        'Update-Column',
                        'Update-Description',
                        'Update-ExtendedProperty',
                        'Update-Row',
                        'Update-StoredProcedure',
                        'Update-Trigger',
                        'Update-UserDefinedFunction',
                        'Update-View'
                      )

Export-ModuleMember -Function $publicFunctions -Alias *
