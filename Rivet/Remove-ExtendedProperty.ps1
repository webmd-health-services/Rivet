function Remove-ExtendedProperty
{
    <#
    .SYNOPSIS
    Drops an extended property for a schema, table, or column.
    
    .DESCRIPTION
    SQL Server has a special stored procedure for removing extended property metatdata about an object.  Unfortunately, it has a really clunky interface.  This function is an attempt to wrap `sp_dropextendedproperty` with a saner interface.
    
    Currently, this function only supports dropping properties for schemas, tables, and columns. Submit a patch!
    
    .LINK
    Add-Description
    
    .LINK
    Add-ExtendedProperty
    
    .LINK
    Remove-Description
    
    .LINK
    Update-Description
    
    .LINK
    Update-ExtendedProperty
    
    .EXAMPLE
    Remove-ExtendedProperty -Name 'Deploy' -SchemaName 'spike'
    
    Drops the custom `Deploy` metadata for the `spike` schema.
    
    .EXAMPLE
    Remove-ExtendedProperty -Name 'Deploy' -TableName 'Food'
    
    Drops the custom `Deploy` metadata on the `Food` table in the `dbo` schema.
    
    .EXAMPLE
    Remove-ExtendedProperty -Name 'IsEncrypted' -TableName 'User' -ColumnName 'Password'
    
    Drops the custom `IsEncrypted` metadata on the `User` table's `Password` column.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name of the extended property to remove.
        $Name,
        
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

    If ($PsCmdlet.ParameterSetName -eq "SCHEMA")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $Name
    }

    If ($PsCmdlet.ParameterSetName -eq "TABLE")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $TableName, $Name
    }

    If ($PsCmdlet.ParameterSetName -eq "COLUMN")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $TableName, $ColumnName, $Name
    }

    Invoke-MigrationOperation -Operation $op 
}