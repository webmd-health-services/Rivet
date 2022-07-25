function Remove-WhsExtendedProperty
{
    <#
    .SYNOPSIS
    Removes the WHS extended properties from an object.
    
    .DESCRIPTION
    SQL Server has a special stored procedure for removing extended property metatdata to an object.  Unfortunately, it has a really clunky interface.  This function is an attempt to wrap `sp_dropextendedproperty` with a saner interface.
    
    Currently, this function only supports updating properties for schemas, tables, and columns.
    
    .EXAMPLE
    Remove-WhsExtendedProperty -TableName 'Employee' -ColumnName 'Address' -PropertyName 'WHS_Encrypted'
    
    Demonstrates how to remove extended property 'WHS_Encrypted' from the `Address` column in the `Employee` table in the `dbo` schema.
    #>

    param(
        [Parameter(Mandatory, ParameterSetName='ForSchema')]
        [String] $SchemaName = 'dbo',
 
        [Parameter(Mandatory, ParameterSetName='ForTable')]
        [Parameter(Mandatory, ParameterSetName='ForTableColumn')]
        [String] $TableName,
 
        [Parameter(Mandatory, ParameterSetName='ForTableColumn')]
        [String] $ColumnName,
 
        [Parameter(Mandatory)]
        [ValidateSet('WHS_ContentType', 'WHS_Encrypted', 'WHS_RelatesTo')]
        [String] $Name
    )

    Set-StrictMode -Version 'Latest'

    if ($PsCmdlet.ParameterSetName -eq "ForSchema")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $Name
    }

    if ($PsCmdlet.ParameterSetName -eq "ForTable")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $TableName, $Name, $false
    }

    if ($PsCmdlet.ParameterSetName -eq "ForTableColumn")
    {
        $op = New-Object 'Rivet.Operations.RemoveExtendedPropertyOperation' $SchemaName, $TableName, $ColumnName, $Name, $false
    }

    return $op
}