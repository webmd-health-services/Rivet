
function Test-DataType
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the data type.
        $Name,

        [string]
        # The name of the schema.
        $SchemaName
    )

    Set-StrictMode -Version 'Latest'

    return ((Get-DataType @PSBoundParameters) -ne $null)
}