
$Connection = New-Object Data.SqlClient.SqlConnection

$RivetSchemaName = 'rivet'
$RivetMigrationsTableName = 'Migrations'
$RivetMigrationsTableFullName = '{0}.{1}' -f $RivetSchemaName,$RivetMigrationsTableName
$RivetActivityTableName = 'Activity'


function Test-TypeDataMember
{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The type name to check.
        $TypeName,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the member to check.
        $MemberName
    )

    Set-StrictMode -Version 'Latest'

    $typeData = Get-TypeData -TypeName $TypeName
    if( -not $typeData )
    {
        # The type isn't defined or there is no extended type data on it.
        return $false
    }

    return $typeData.Members.ContainsKey( $MemberName )
}

if( -not (Test-TypeDataMember -TypeName 'Rivet.OperationResult' -MemberName 'MigrationID') )
{
    Update-TypeData -TypeName 'Rivet.OperationResult' -MemberType ScriptProperty -MemberName 'MigrationID' -Value { $this.Migration.ID }
}

$publicFunctions = @()
Invoke-Command -ScriptBlock {
                                Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Functions' -Resolve) -Filter '*-*.ps1'
                                Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Operations' -Resolve) -Filter '*-*.ps1' |
                                    Tee-Object -Variable 'script:publicFunctions'
                            } |
    Where-Object { $_.BaseName -ne 'Export-Row' } |
    ForEach-Object { . $_.FullName }

$publicFunctions = $publicFunctions | Select-Object -ExpandProperty 'BaseName'

$publicFunctions += @(
                        'Add-CheckConstraint',
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
                        'Add-UniqueKey',
                        'Add-UserDefinedFunction',
                        'Add-View',
                        'Get-Migration',
                        'Get-RivetConfig',
                        'Invoke-Ddl',
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
                        'Remove-CheckConstraint',
                        'Remove-DataType',
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
                        'Remove-UniqueKey',
                        'Remove-UserDefinedFunction',
                        'Remove-Trigger',
                        'Remove-View',
                        'Rename-Column',
                        'Rename-Constraint',
                        'Rename-DataType',
                        'Rename-Index',
                        'Rename-Object',
                        'Set-StoredProcedure',
                        'Set-UserDefinedFunction',
                        'Set-View',
                        'Update-CodeObjectMetadata',
                        'Update-Description',
                        'Update-ExtendedProperty',
                        'Update-Row',
                        'Update-StoredProcedure',
                        'Update-Table',
                        'Update-Trigger',
                        'Update-UserDefinedFunction',
                        'Update-View'
                      )

Export-ModuleMember -Function $publicFunctions -Alias *
