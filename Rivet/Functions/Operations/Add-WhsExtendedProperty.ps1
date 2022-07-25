function Add-WhsExtendedProperty
{
    <#
    .SYNOPSIS
    Adds the WHS extended properties to an object.
    
    .DESCRIPTION
    SQL Server has a special stored procedure for adding extended property metatdata to an object.  Unfortunately, it has a really clunky interface.  This function is an attempt to wrap `sp_addextendedproperty` with a saner interface.
    
    Currently, this function only supports updating properties for schemas, tables, and columns.
    
    .EXAMPLE
    Add-WhsExtendedProperty -TableName 'Employee' -ColumnName 'Address' -ContentType 'PII' -Encrypted $True -RelatesTo @('Stuff')
    
    Demonstrates how to Add WHS extended properties to the `Address` column in the `Employee` table in the `dbo` schema.

    The extended properties should be named: WHS_ContentTyp, WHS_Encrypted, WHS_RelatesTo
    WHS_Content specifies whether the column contains PHI, PII, both, or none.
    WHS_Encrypted specifies whether information in this column is encrypted or not.
    WHS_RelatesTo specifies what the column relates to.
    #>

    param(
        # The schema of the object.
        [Parameter(ParameterSetName='ForSchema')]
        [String] $SchemaName = 'dbo',
 
        # The table name.
        [Parameter(Mandatory, ParameterSetName='ForTable')]
        [Parameter(Mandatory, ParameterSetName='ForTableColumn')]
        [String] $TableName,

        # The column name
        [Parameter(Mandatory, ParameterSetName='ForTableColumn')]
        [String] $ColumnName,
 
        # The content type of the extended property.
        [Parameter(Mandatory)]
        [ValidateSet('NotProtected', 'PHI', 'PII', 'PHIAndPII')]
        [string] $ContentType,
 
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [String[]] $RelatesTo,

        [Parameter(Mandatory)]
        [bool] $Encrypted
    )

    Set-StrictMode -Version 'Latest'

    $whsExtendedProperties = @{
        WHS_ContentType = $ContentType
        WHS_Encrypted = $Encrypted
        WHS_RelatesTo = $RelatesTo -join ', '
    }

    $ops = @()
    
    $whsExtendedProperties.Keys | Foreach-Object {
        $name = $_
        $value = $whsExtendedProperties[$_]

        if ($PsCmdlet.ParameterSetName -eq "ForSchema")
        {
            $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $name, $value
        }
    
        if ($PsCmdlet.ParameterSetName -eq "ForTable")
        {
            $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $TableName, $name, $value, $false
        }
    
        if ($PsCmdlet.ParameterSetName -eq "ForTableColumn")
        {
            $op = New-Object 'Rivet.Operations.AddExtendedPropertyOperation' $SchemaName, $TableName, $ColumnName, $name, $value, $false
        }

        $ops = $ops += $op
    }

    return $ops
}