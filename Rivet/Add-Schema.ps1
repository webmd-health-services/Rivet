
function Add-Schema
{
    <#
    .SYNOPSIS
    Creates a new schema.

    .DESCRIPTION
    The `Add-Schema` operation creates a new schema in a database. It does so in an idempotent way, i.e. it only creates the schema if it doesn't exist. 

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

    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.AddSchemaOperation' $Name, $Owner
}