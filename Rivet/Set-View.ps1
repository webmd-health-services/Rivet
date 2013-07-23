
function Set-View
{
    <#
    .SYNOPSIS
    Creates or updates a view from a script file.
    
    .DESCRIPTION
    The view should be in the `$Database\Views` directory, in a file with the same name as the view, e.g. `$Name.sql`.  If the schema is *not* `dbo`, it should be at the front of the filename, e.g. `rivet.Migrators`.

    If the view exists, it is dropped before applying the new view from the script file.
        
    .EXAMPLE
    Set-View -Name InsertMigration

    Drops the `InsertMigration` view (if it exists), then executes the contents of the `$Database\Views\InsertMigration.sql` file.
    
    .EXAMPLE
    Set-View -Name InsertMigration -Schema rivet
    
    Drops the `rivet.InsertMigration` view (it it exists), then executes the contents of the `$Database\Views\rivet.InsertMigration.sql` file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the view to create/update.
        $Name,
        
        [Parameter()]
        [string]
        # The schema of the view. Default is `dbo`.
        $Schema = 'dbo'
    )
    
    $scriptPath = Resolve-ObjectScriptPath -View -Name $Name -Schema $Schema
    Remove-View -Name $Name -Schema $Schema -IfExists
    Invoke-SqlScript -Path $ScriptPath
}