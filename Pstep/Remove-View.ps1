
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
    Remove-View -Name MyView -Schema pstep
    
    Removes the `pstep.MyView` view.
    
    .EXAMPLE
    Remove-View -Name MyView -IfExists
    
    Deletes the `dbo.MyView` view only if it exists.
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
        $Schema,
        
        [Switch]
        # Only deletes the view if it exists.
        $IfExists
    )
    
    $query = 'DROP VIEW [{0}].[{1}]' -f $Schema,$Name
    
    if( $IfExists )
    {
        $query = @'
        IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[{0}].[{1}]') )
            {2}
'@ -f $Schema,$Name,$query
    }
    
    Invoke-Query -Query $query
}