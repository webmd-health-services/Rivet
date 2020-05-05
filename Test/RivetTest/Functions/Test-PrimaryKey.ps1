
function Test-PrimaryKey
{
    <#
    .SYNOPSIS
    Tests that a primary key exists on the given table.
    #>
    param(
        [Parameter(ParameterSetName='ByTable')]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ByTable')]
        [string]
        # The name of the table whose primary key to get.
        $TableName,

        [Parameter(Mandatory=$true,ParameterSetName='ByName')]
        [string]
        # The name of the primary key.
        $Name
    )

    Set-StrictMode -Version Latest

    return ((Get-PrimaryKey @PSBoundParameters) -ne $null)
}
