
function Add-Description
{
    <#
    .SYNOPSIS
    Adds the `MS_Description` extended property to schemas, tables, columns, views, and view columns.

    .DESCRIPTION
    The `sys.sp_addextendedproperty` stored procedure is used to set a table/column's description (i.e. the `MS_Description` extended property), but the syntax is weird.  This function hides that weirdness from you.  You're welcome.

    .EXAMPLE
    Add-Description -Description 'Whoseit's whatsits table.' -TableName WhoseitsWhatsits 

    Adds a description (i.e. the `MS_Description` extended property) on the `WhoseitsWhatsits` table.

    .EXAMPLE
    Add-Description  -Description 'Is it a snarfblat?' -TableName WhoseitsWhatsits -ColumnName IsSnarfblat

    Adds a description (i.e. the `MS_Description` extended property) on the `WhoseitsWhatsits` table's `IsSnarfblat` column.
    
    .EXAMPLE
    Add-Description -Description 'Whoseit's whatsits table.' -TableName WhoseitsWhatsits -ForTable
    
    PowerShell v2.0 doesn't parse the parameters correctly when setting a table name, so you have to explicitly tell it what to do.  Upgrade to PowerShell 3!

    .EXAMPLE
    Add-Description -Description 'This is an extended property on a schema' -SchemaName 'test'

    Adds a description (i.e. the `MS_Description` extended property) on the `test` schema.

    .EXAMPLE
    Add-Description -Description 'This is an extended property on a view' -SchemaName 'test' -ViewName 'testVw'

    Adds a description (i.e. the `MS_Description` extended property) on the `testVw` view.
    
    .EXAMPLE
    Add-Description -Description 'This is an extended property on a view column' -SchemaName 'test' -ViewName 'testVw' -ColumnName 'ID'

    Adds a description (i.e. the `MS_Description` extended property) on the `ID` column in the 'testVw' view.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The value for the MS_Description extended property.
        $Description,

        [Parameter(ParameterSetName='ForSchema')]
        [Parameter(ParameterSetName='ForTable')]
        [Parameter(ParameterSetName='ForView')]
        [Parameter(ParameterSetName='ForColumn')]
        [Alias('Schema')]
        [string]
        # The schema.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ForTable')]
        [Parameter(Mandatory=$true,ParameterSetName='ForColumn')]
        [Alias('Table')]
        [string]
        # The name of the table where the extended property is getting set.
        $TableName,

        [Parameter(Mandatory=$true,ParameterSetName='ForView')]
        [Alias('View')]
        [string]
        # The name of the view where the extended property is getting set.
        $ViewName,

        [Parameter(Mandatory=$true,ParameterSetName='ForColumn')]
        [Alias('Column')]
        [string]
        # The name of the column where the extended property is getting set.
        $ColumnName
    )

    $optionalArgs = @{ }
    if( $TableName )
    {
        $optionalArgs.TableName = $TableName
    }
    if( $ViewName )
    {
        $optionalArgs.ViewName = $ViewName
    }
    if( $ColumnName )
    {
        $optionalArgs.ColumnName = $ColumnName
    }

    Add-ExtendedProperty -Name ([Rivet.Operations.ExtendedPropertyOperation]::DescriptionPropertyName) `
                         -Value $Description `
                         -SchemaName $SchemaName `
                         @optionalArgs
}