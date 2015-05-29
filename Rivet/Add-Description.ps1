
function Add-Description
{
    <#
    .SYNOPSIS
    Adds the `MS_Description` extended property to a table or column.

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
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The value for the MS_Description extended property.
        $Description,

        [Alias('Schema')]
        [string]
        # The schema.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [Alias('Table')]
        [string]
        # The name of the table where the extended property is getting set.
        $TableName,

        [Parameter(ParameterSetName='ForColumn')]
        [Alias('Column')]
        [string]
        # The name of the column where the extended property is getting set.
        $ColumnName
    )

    $optionalArgs = @{ }
    if( $ColumnName )
    {
        $optionalArgs.ColumnName = $ColumnName
    }

    Add-ExtendedProperty -Name 'MS_Description' `
                         -Value $Description `
                         -SchemaName $SchemaName `
                         -TableName $TableName `
                         @optionalArgs
}