
$Connection = New-Object Data.SqlClient.SqlConnection
$Connection | 
    Add-Member -MemberType NoteProperty -Name ScriptsPath -Value $null

$RivetSchemaName = 'rivet'
$RivetMigrationsTableName = 'Migrations'
$RivetMigrationsTableFullName = '{0}.{1}' -f $RivetSchemaName,$RivetMigrationsTableName

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-Rivet' -and $_.BaseName -ne 'Get-Migration' } |
    ForEach-Object { . $_.FullName }

$publicFunctions = @(
                        'Add-Column',
                        'Add-DefaultConstraint',
                        'Add-Description',
                        'Add-ForeignKey',
                        'Add-Index',
                        'Add-PrimaryKey',
                        'Add-Schema',
                        'Add-StoredProcedure',
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
                        'Remove-ForeignKey',
                        'Remove-Index',
                        'Remove-PrimaryKey',
                        'Remove-Row',
                        'Remove-Schema',
                        'Remove-StoredProcedure',
                        'Remove-Table',
                        'Remove-UniqueConstraint',
                        'Remove-UserDefinedFunction',
                        'Remove-Trigger',
                        'Remove-View',
                        'Update-Description',
                        'Update-Row'
                      )

Export-ModuleMember -Function $publicFunctions
