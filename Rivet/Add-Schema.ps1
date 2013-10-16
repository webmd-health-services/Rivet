
function Add-Schema
{
    <#
    .SYNOPSIS
    Creates a new schema.

    .EXAMPLE
    Add-Schema -Name 'rivetexample'

    Creates the `rivetexample` schema.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [Alias('SchemaName')]
        [string]
        # The name of the schema.
        $Name,

        [Alias('Authorization')]
        [string]
        # The owner of the schema.
        $Owner
    )

    Write-Host (" +{0} {1}" -f $Name, $Owner)
    $op = New-Object 'Rivet.Operations.AddSchemaOperation' $Name, $Owner
    Invoke-MigrationOperation -Operation $op
}