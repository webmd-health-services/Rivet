function Add-ExtendedProperty
{
    <#
    .SYNOPSIS
    Adds an extended property for a schema, table, or column.
    
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
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name of the extended property to add.
        $Name,
        
        [Parameter(Mandatory=$true,Position=2)]
        [AllowNull()]
        # The value of the extended property.
        $Value,

        [Parameter(ParameterSetName='SCHEMA')]
        [Parameter(ParameterSetName='TABLE')]
        [Parameter(ParameterSetName='COLUMN')]
        [string]
        # The schema of the object.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,ParameterSetName='TABLE')]
        [Parameter(Mandatory=$true,ParameterSetName='COLUMN')]
        [string]
        # The table name.
        $TableName,
        
        [Parameter(Mandatory=$true,ParameterSetName='COLUMN')]
        [string]
        # The column name.
        $ColumnName
    )

    if ($PsCmdlet.ParameterSetName -eq "SCHEMA")
    {
        $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $Name, $Value
    }

    if ($PsCmdlet.ParameterSetName -eq "TABLE")
    {
        $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $TableName, $Name, $Value
    }

    if ($PsCmdlet.ParameterSetName -eq "COLUMN")
    {
        $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $TableName, $ColumnName, $Name, $Value
    }

    Invoke-MigrationOperation -Operation $op
}