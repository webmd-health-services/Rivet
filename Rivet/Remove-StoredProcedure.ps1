
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
        $Schema = 'dbo'
        
    )
    
    $query = 'DROP PROCEDURE [{0}].[{1}]' -f $Schema,$Name

    $op = New-Object 'Rivet.Operations.RawQueryOperation' $query
    Invoke-MigrationOperation -Operation $op
}