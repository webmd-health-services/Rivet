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

    .EXAMPLE
    Update-ExtendedProperty -Name 'ContainsPII' -Value 'FALSE' -View 'LoggedInUsers'
    
    Demonstrates how to update custom metadata on the `LoggedInUsers` view

    .EXAMPLE
    Update-ExtendedProperty -Name 'IsEncrypted' -Value 'FALSE' -View 'LoggedInUsers' -ColumnName 'Password'
    
    Demonstrates how to update custom metadata for a view's column

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the extended property to update.
        $Name,
        
        [Parameter(Mandatory=$true,Position=1)]
        [AllowNull()]
        # The value of the extended property.
        $Value,
        
        [Parameter(ParameterSetName='SCHEMA')]
        [Parameter(ParameterSetName='TABLE')]
        [Parameter(ParameterSetName='TABLE-COLUMN')]
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
        $ColumnName,

        [Switch]
        # Don't output any host message.
        $Quiet
    )

    $objectName = ''
    if ($PsCmdlet.ParameterSetName -eq "SCHEMA")
    {
        $op = New-Object 'Rivet.Operations.UpdateExtendedPropertyOperation' $SchemaName, $Name, $Value
        $objectName = $SchemaName
    }

    if ($PsCmdlet.ParameterSetName -eq "TABLE")
    {
        $op = New-Object 'Rivet.Operations.UpdateExtendedPropertyOperation' $SchemaName, $TableName, $Name, $Value, $false
        $objectName = '{0}.{1}' -f $SchemaName,$TableName
    }

    if ($PsCmdlet.ParameterSetName -eq "VIEW")
    {
        $op = New-Object 'Rivet.Operations.UpdateExtendedPropertyOperation' $SchemaName, $ViewName, $Name, $Value, $true
        $objectName = '{0}.{1}' -f $SchemaName,$ViewName
    }

    if ($PsCmdlet.ParameterSetName -eq "TABLE-COLUMN")
    {
        $op = New-Object 'Rivet.Operations.UpdateExtendedPropertyOperation' $SchemaName, $TableName, $ColumnName, $Name, $Value, $false
        $objectName = '{0}.{1}.{2}' -f $SchemaName,$TableName,$ColumnName
    }

    if ($PsCmdlet.ParameterSetName -eq "VIEW-COLUMN")
    {
        $op = New-Object 'Rivet.Operations.UpdateExtendedPropertyOperation' $SchemaName, $ViewName, $ColumnName, $Name, $Value, $true
        $objectName = '{0}.{1}.{2}' -f $SchemaName,$ViewName,$ColumnName
    }

    if( -not $Quiet )
    {
        Write-Host (' {0} ={1}' -f $objectName,$Name)
    }
    Invoke-MigrationOperation -Operation $op  
}