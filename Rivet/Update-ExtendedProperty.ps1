function Update-ExtendedProperty
{
    <#
    .SYNOPSIS
    Updates an object's extended property.
    
    .DESCRIPTION
    SQL Server has a special stored procedure for updating extended property metatdata about an object.  Unfortunately, it has a really clunky interface.  This function is an attempt to wrap `sp_updateextendedproperty` with a saner interface.
    
    Currently, this function only supports updating properties for schemas, tables, and columns. Submit a patch!
    
    .LINK
    Add-Description
    
    .LINK
    Add-ExtendedProperty
    
    .LINK
    Remove-Description
    
    .LINK
    Remove-ExtendedProperty
    
    .LINK
    Update-Description
    
    .LINK
    Update-ExtendedProperty
    
    .EXAMPLE
    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -SchemaName 'spike'
    
    Sets the custom `Deploy` metadata to be `FALSE`.
    
    .EXAMPLE
    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -TableName 'Food'
    
    Sets the custom `Deploy` metadata to be `FALSE` on the `Food` table in the `dbo` schema.
    
    .EXAMPLE
    Update-ExtendedProperty -Name 'IsEncrypted' -Value 'TRUE' -TableName 'User' -ColumnName 'Password'
    
    Sets the custom `IsEncrypted` metadata to be `TRUE` on the `User` table's `Password` column.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name of the extended property to update.
        $Name,
        
        [Parameter(Mandatory=$true,Position=2)]
        [string]
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

    If ($PsCmdlet.ParameterSetName -eq "SCHEMA")
    {
        $op = New-Object 'Rivet.Operations.UpdateExtendedPropertyOperation' $SchemaName, $Name, $Value
    }

    If ($PsCmdlet.ParameterSetName -eq "TABLE")
    {
        $op = New-Object 'Rivet.Operations.UpdateExtendedPropertyOperation' $SchemaName, $TableName, $Name, $Value
    }

    If ($PsCmdlet.ParameterSetName -eq "COLUMN")
    {
        $op = New-Object 'Rivet.Operations.UpdateExtendedPropertyOperation' $SchemaName, $TableName, $ColumnName, $Name, $Value
    }

    Invoke-MigrationOperation -Operation $op  
}