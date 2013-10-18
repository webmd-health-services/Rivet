
function Remove-Schema
{
    <#
    .SYNOPSIS
    Removes a schema.

    .EXAMPLE
    Remove-Schema -Name 'rivetexample'

    Drops/removes the `rivetexample` schema.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [Alias('SchemaName')]
        [string]
        # The name of the schema.
        $Name
    )

    Write-Host (' -{0}' -f $Name)
    $op = New-Object 'Rivet.Operations.RemoveSchemaOperation' $Name
    Invoke-MigrationOperation -Operation $op
}