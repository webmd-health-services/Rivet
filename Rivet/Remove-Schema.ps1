
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

    $query = 'drop schema [{0}]' -f $Name
    Write-Host (' -{0}' -f $Name)
    
    #Construct Migration Object

    $migration = New-MigrationObject -Property @{ Query = $query } -ToQueryMethod { return $this.Query }

    Invoke-Migration -Migration $migration 
}