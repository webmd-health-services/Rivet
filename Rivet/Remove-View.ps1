
function Remove-View
{
    <#
    .SYNOPSIS
    Removes a view.
    
    .DESCRIPTION
    Removes a view.  Will throw an exception and rollback the migration if the view doesn't exist.
    
    By default, the view is assumed to be in the `dbo` schema.  Use the `Schema` parameter to specify a different schema.   
    
    You can conditionally delete a view only if it exists using the `IfExists` switch.
     
    .EXAMPLE
    Remove-View -Name MyView
    
    Removes the `dbo.MyView` view.
    
    .EXAMPLE
    Remove-View -Name MyView -SchemaName rivet
    
    Removes the `rivet.MyView` view.
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the view to remove/delete.
        $Name,
        
        [Parameter()]
        [string]
        # The schema of the view.  Default is `dbo`.
        $SchemaName = 'dbo'
    )
    
    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.RemoveViewOperation' $SchemaName, $Name
}