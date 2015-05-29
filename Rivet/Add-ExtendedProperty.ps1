function Add-ExtendedProperty
{
    <#
    .SYNOPSIS
    Adds an extended property for a schema, table, view or column.
    
    .DESCRIPTION
    SQL Server has a special stored procedure for adding extended property metatdata about an object.  Unfortunately, it has a really clunky interface.  This function is an attempt to wrap `sp_addextendedproperty` with a saner interface.
    
    Currently, this function only supports adding properties for schemas, tables, and columns. Submit a patch!
    
    .LINK
    Add-Description
    
    .LINK
    Remove-Description
    
    .LINK
    Remove-ExtendedProperty
    
    .LINK
    Update-Description
    
    .LINK
    Update-ExtendedProperty
    
    .EXAMPLE
    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -SchemaName 'spike'
    
    Adds custom `Deploy` metadata for the `spike` schema.
    
    .EXAMPLE
    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Food'
    
    Adds custom `Deploy` metadata on the `Food` table in the `dbo` schema.
    
    .EXAMPLE
    Add-ExtendedProperty -Name 'IsEncrypted' -Value 'FALSE' -TableName 'User' -ColumnName 'Password'
    
    Adds custom `IsEncrypted` metadata on the `User` table's `Password` column.

    .EXAMPLE
    Add-ExtendedProperty -Name 'ContainsPII' -Value 'FALSE' -View 'LoggedInUsers'
    
    Demonstrates how to add custom metadata on the `LoggedInUsers` view

    .EXAMPLE
    Add-ExtendedProperty -Name 'IsEncrypted' -Value 'FALSE' -View 'LoggedInUsers' -ColumnName 'Password'

    Demonstrates how to add custom metadata for a view's column
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the extended property to add.
        $Name,
        
        [Parameter(Mandatory=$true,Position=1)]
        [AllowNull()]
        # The value of the extended property.
        $Value,
        
        [Parameter(ParameterSetName='SCHEMA')]
        [Parameter(ParameterSetName='TABLE')]
        [Parameter(ParameterSetName='TABLE-COLUMN')]
        [Parameter(ParameterSetName='VIEW')]
        [Parameter(ParameterSetName='VIEW-COLUMN')]
        [string]
        # The schema of the object.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,ParameterSetName='TABLE')]
        [Parameter(Mandatory=$true,ParameterSetName='TABLE-COLUMN')]
        [Alias('Table')]
        [string]
        # The table name.
        $TableName,
        
        [Parameter(Mandatory=$true,ParameterSetName='VIEW')]
        [Parameter(Mandatory=$true,ParameterSetName='VIEW-COLUMN')]
        [Alias('View')]
        [string]
        # The table name.
        $ViewName,        
        
        [Parameter(Mandatory=$true,ParameterSetName='VIEW-COLUMN')]
        [Parameter(Mandatory=$true,ParameterSetName='TABLE-COLUMN')]
        [Alias('Column')]
        [string]
        # The column name.
        $ColumnName
    )

    Set-StrictMode -Version 'Latest'
    
    $objectName = ''
    if ($PsCmdlet.ParameterSetName -eq "SCHEMA")
    {
        $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $Name, $Value
        $objectName = $SchemaName
    }

    if ($PsCmdlet.ParameterSetName -eq "TABLE")
    {
        $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $TableName, $Name, $Value, $false
        $objectName = '{0}.{1}' -f $SchemaName,$TableName
    }

    if ($PsCmdlet.ParameterSetName -eq "VIEW")
    {
        $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $ViewName, $Name, $Value, $true
        $objectName = '{0}.{1}' -f $SchemaName,$ViewName
    }

    if ($PsCmdlet.ParameterSetName -eq "TABLE-COLUMN")
    {
        $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $TableName, $ColumnName, $Name, $Value, $false
        $objectName = '{0}.{1}.{2}' -f $SchemaName,$TableName,$ColumnName
    }

    if ($PsCmdlet.ParameterSetName -eq "VIEW-COLUMN")
    {
        $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $ViewName, $ColumnName, $Name, $Value, $true
        $objectName = '{0}.{1}.{2}' -f $SchemaName,$ViewName,$ColumnName
    }

    Write-Verbose (' {0} +{1}' -f $objectName,$Name)
    return $op
}