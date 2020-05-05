
function Test-ExtendedProperty
{
    [CmdletBinding()]
    param(
        [string]
        $SchemaName = 'dbo',

        [string]
        $TableName,

        [string]
        $ColumnName,

        [string]
        $ViewName,

        [string]
        $Name
    )

    return ((Get-ExtendedProperty @PSBoundParameters) -ne $null)
}
