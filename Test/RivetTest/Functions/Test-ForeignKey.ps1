
function Test-ForeignKey
{
    <#
    .SYNOPSIS
    Tests if a foreign key exists between two tables.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose foreign key to get.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The table that the foreign key references
        $References,

        [Parameter()]
        [string]
        # The schema name of the reference table.  Defaults to `dbo`.
        $ReferencesSchema = 'dbo'        
    )
    
    Set-StrictMode -Version Latest

    return ((Get-ForeignKey @PSBoundParameters) -ne $null)
}
