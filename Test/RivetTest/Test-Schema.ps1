
function Test-Schema
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the schema to test.
        $Name
    )
    
    Set-StrictMode -Version Latest

    $schema = Get-Schema -Name $Name
    return ($schema -ne $null)
}
