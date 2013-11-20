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

    .EXAMPLE
    Remove-ExtendedProperty -Name 'ContainsPII' -View 'LoggedInUsers'
    
    Demonstrates how to remove custom metadata on the `LoggedInUsers` view

    .EXAMPLE
    Remove-ExtendedProperty -Name 'IsEncrypted' -View 'LoggedInUsers' -ColumnName 'Password'
    
    Demonstrates how to remove custom metadata for a view's column
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the extended property to add.
        $Name,
        
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
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $Name
        $objectName = $SchemaName
    }

    if ($PsCmdlet.ParameterSetName -eq "TABLE")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $TableName, $Name, $false
        $objectName = '{0}.{1}' -f $SchemaName,$TableName
    }

    if ($PsCmdlet.ParameterSetName -eq "VIEW")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $ViewName, $Name, $true
        $objectName = '{0}.{1}' -f $SchemaName,$ViewName
    }

    if ($PsCmdlet.ParameterSetName -eq "TABLE-COLUMN")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $TableName, $ColumnName, $Name, $false
        $objectName = '{0}.{1}.{2}' -f $SchemaName,$TableName,$ColumnName
    }

    if ($PsCmdlet.ParameterSetName -eq "VIEW-COLUMN")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $ViewName, $ColumnName, $Name, $true
        $objectName = '{0}.{1}.{2}' -f $SchemaName,$ViewName,$ColumnName
    }

    if( -not $Quiet )
    {
        Write-Host (' {0} -{1}' -f $objectName,$Name)
    }
    Invoke-MigrationOperation -Operation $op 
}