
function Test-Index
{
    <#
    .SYNOPSIS
    Tests that an index exists.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='ByObject')]
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ByObject')]
        [string]
        # The name of the table whose primary key to get.
        $TableName,

        [Parameter(ParameterSetName='ByObject')]
        [string[]]
        # Array of Column Names
        $ColumnName,

        [Parameter(ParameterSetName='ByObject')]
        [Switch]
        # Get a unique index.
        $Unique,

        [Parameter(Mandatory=$true,ParameterSetName='ByName')]
        $Name
    )

    Set-StrictMode -Version 'Latest'

    return ((Get-Index @PSBoundParameters) -ne $null)   
}
