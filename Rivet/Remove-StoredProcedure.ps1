
function Remove-StoredProcedure
{
    <#
    .SYNOPSIS
    Removes a stored procedure.
    
    .DESCRIPTION
    Removes a stored procedure.  Will throw an exception and rollback the migration if the stored procedure doesn't exist.
    
    By default, the stored procedure is assumed to be in the `dbo` schema.  Use the `Schema` parameter to specify a different schema.   
    
    You can conditionally delete a stored procedure only if it exists using the `IfExists` switch.
     
    .EXAMPLE
    Remove-StoredProcedure -Name MySproc
    
    Removes the `dbo.MySproc` stored procedure.
    
    .EXAMPLE
    Remove-StoredProcedure -Name MySproc -Schema rivet
    
    Removes the `rivet.MySproc` stored procedure.
    
    .EXAMPLE
    Remove-StoredProcedure -Name MySproc -IfExists
    
    Deletes the `dbo.MySproc` stored procedure only if it exists.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the stored procedure to remove/delete.
        $Name,
        
        [Parameter()]
        [string]
        # The schema of the stored procedure.  Default is `dbo`.
        $Schema = 'dbo',
        
        [Switch]
        # Only deletes the stored procedure if it exists.
        $IfExists
    )
    
    $query = 'DROP PROCEDURE [{0}].[{1}]' -f $Schema,$Name
    
    if( $IfExists )
    {
        $query = @'
        IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[{0}].[{1}]') AND type in (N'P', N'PC'))
            {2}
'@ -f $Schema,$Name,$query
    }
    
    Invoke-Query -Query $query
}