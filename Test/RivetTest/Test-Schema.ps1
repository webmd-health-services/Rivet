
function Test-Schema
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the schema to test.
        $Name
    )
    
    $schema = Get-Schema -Name $schema
    return ($schema -ne $null)
}