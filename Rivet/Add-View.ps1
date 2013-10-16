 function Add-View
 {
    <#
    .SYNOPSIS
    Creates a new view.

    .DESCRIPTION
    Creates a new view.

    .EXAMPLE
    Add-View -SchemaName 'rivet' 'ReadMigrations' 'AS select * from rivet.Migrations'

    Creates a view to read all the migrations from Rivet's Migrations table.  Don't do this in real life.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the view.
        $Name,
        
        [Parameter()]
        [string]
        # The schema name of the view.  Defaults to `dbo`.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The definition of the view.
        $Definition
    )
    
    $op = New-Object Rivet.Operations.AddViewOperation $SchemaName,$Name,$Definition
    Write-Host(' +[{0}].[{1}]' -f $SchemaName,$Name)
    Invoke-MigrationOperation -Operation $op
}