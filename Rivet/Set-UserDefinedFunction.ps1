
function Set-UserDefinedFunction
{
    <#
    .SYNOPSIS
    Creates or updates a stored procedure from a script file.
    
    .DESCRIPTION
    The stored procedure should be in the `$Database\Stored Procedures` directory, in a file with the same name as the stored procedure, e.g. `$Name.sql`.  If the schema is *not* `dbo`, it should be at the front of the filename, e.g. `rivet.Migrators`.

    If the stored procedure exists, it is dropped before applying the new stored procedure from the script file.
        
    .EXAMPLE
    Set-StoredProcedure -Name InsertMigration

    Drops the `InsertMigration` stored procedure (if it exists), then executes the contents of the `$Database\Stored Procedures\InsertMigration.sql` file.
    
    .EXAMPLE
    Set-StoredProcedure -Name InsertMigration -Schema rivet
    
    Drops the `rivet.InsertMigration` stored procedure (it it exists), then executes the contents of the `$Database\Stored Procedures\rivet.InsertMigration.sql` file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the stored procedure to create/update.
        $Name,
        
        [Parameter()]
        [string]
        # The schema of the stored procedure. Default is `dbo`.
        $Schema = 'dbo'
    )
    
    $scriptPath = Resolve-ObjectScriptPath -UserDefinedFunction -Name $Name -Schema $Schema
    Invoke-SqlScript -Path $ScriptPath
}