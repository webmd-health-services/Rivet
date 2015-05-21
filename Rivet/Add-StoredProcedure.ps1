function Add-StoredProcedure
{
    <#
    .SYNOPSIS
    Creates a new stored procedure.

    .DESCRIPTION
    Creates a new stored procedure.

    .EXAMPLE
    Add-StoredProcedure -SchemaName 'rivet' 'ReadMigrations' 'AS select * from rivet.Migrations'

    Creates a stored procedure to read the migrations from Rivet's Migrations table.  Note that in real life, you probably should leave my table alone.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the stored procedure.
        $Name,
            
        [Parameter()]
        [string]
        # The schema name of the stored procedure.  Defaults to `dbo`.
        $SchemaName = 'dbo',
            
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The store procedure's definition, which is everything after the `create procedure [schema].[name]` clause.
        $Definition
    )
        
    $op = New-Object 'Rivet.Operations.AddStoredProcedureOperation' $SchemaName, $Name, $Definition
    Write-Host(' +{0}.{1}' -f $SchemaName,$Name)
    Invoke-MigrationOperation -operation $op
}