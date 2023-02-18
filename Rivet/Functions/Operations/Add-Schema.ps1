
function Add-Schema
{
    <#
    .SYNOPSIS
    Creates a new schema.

    .DESCRIPTION
    The `Add-Schema` operation creates a new schema in a database. It does so in an idempotent way, i.e. it only
    creates the schema if it doesn't exist. If -Description is provided an extended property named 'MS_Description'
    will be added to the schema with the description as the value.

    .EXAMPLE
    Add-Schema -Name 'rivetexample'

    Creates the `rivetexample` schema.

    .EXAMPLE
    Add-Schema -Name 'rivetTest' -Description 'This is an extended property'

    Creates the `rivetTest` schema with the `MS_Description` extended property.
    #>
    [CmdletBinding()]
    param(
        # The name of the schema.
        [Parameter(Mandatory)]
        [Alias('SchemaName')]
        [String] $Name,

        # The owner of the schema.
        [Alias('Authorization')]
        [String] $Owner,

        # A description of the schema.
        [String] $Description
    )

    Set-StrictMode -Version 'Latest'
    
    $schemaOp = New-Object 'Rivet.Operations.AddSchemaOperation' $Name, $Owner

    if( $Description )
    {
        $schemaDescriptionOp = Add-Description -SchemaName $Name -Description $Description 
        $schemaOp.ChildOperations.Add($schemaDescriptionOp)
    }

    $schemaOp | Write-Output
    $schemaOp.ChildOperations | Write-Output
}