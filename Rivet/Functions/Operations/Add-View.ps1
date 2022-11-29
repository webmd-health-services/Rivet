 function Add-View
 {
    <#
    .SYNOPSIS
    Creates a new view.

    .DESCRIPTION
    Creates a new view. If -Description is provided an extended property named 'MS_Description' will be added to the
    schema with the description as the value.

    .EXAMPLE
    Add-View -SchemaName 'rivet' 'ReadMigrations' 'AS select * from rivet.Migrations'

    Creates a view to read all the migrations from Rivet's Migrations table.  Don't do this in real life.

    .EXAMPLE
    Add-View -Name 'rivetVw' -Description 'This is an extended property'

    Creates the `rivetVw` view with the `MS_Description` extended property.
    #>
    [CmdletBinding()]
    param(
        # The name of the view.
        [Parameter(Mandatory, Position=0)]
        [String] $Name,
        
        # The schema name of the view.  Defaults to `dbo`.
        [Parameter()]
        [String] $SchemaName = 'dbo',
        
        # The definition of the view. Everything after the `create view [schema].[name]` clause.
        [Parameter(Mandatory, Position=1)]
        [String] $Definition,

        # A description of the view.
        [String] $Description
    )
    
    Set-StrictMode -Version 'Latest'

    $viewOp = New-Object 'Rivet.Operations.AddViewOperation' $SchemaName,$Name,$Definition

    if( $Description )
    {
        $viewDescriptionOp = Add-Description -SchemaName $SchemaName -ViewName $Name -Description $Description 
        $viewOp.ChildOperations.Add($viewDescriptionOp)
    }

    $viewOp | Write-Output
    $viewOp.ChildOperations | Write-Output
}