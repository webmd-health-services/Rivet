
function Test-Row
{
    param(
        [string]
        $SchemaName = 'dbo',
        
        [string]
        $TableName,

        [string]
        $Where
    )
    
    Set-StrictMode -Version Latest

    return ((Get-Row @PSBoundParameters) -ne $null)
}
