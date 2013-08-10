
function Remove-UserDefinedFunction
{
    <#
    .SYNOPSIS
    Removes a user-defined function.
    
    .DESCRIPTION
    Removes a user-defined function.  Will throw an exception and rollback the migration if the user-defined function doesn't exist.
    
    By default, the user-defined function is assumed to be in the `dbo` schema.  Use the `Schema` parameter to specify a different schema.   
    
    You can conditionally delete a user-defined function only if it exists using the `IfExists` switch.
     
    .EXAMPLE
    Remove-UserDefinedFunction -Name MyFunc
    
    Removes the `dbo.MyFunc` user-defined function.
    
    .EXAMPLE
    Remove-UserDefinedFunction -Name MyFunc -Schema rivet
    
    Removes the `rivet.MyFunc` user-defined function.
    
    .EXAMPLE
    Remove-UserDefinedFunction -Name MyFunc -IfExists
    
    Deletes the `dbo.MyFunc` user-defined function only if it exists.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the user-defined function to remove/delete.
        $Name,
        
        [Parameter()]
        [string]
        # The schema of the user-defined function.  Default is `dbo`.
        $Schema = 'dbo',
        
        [Switch]
        # Only deletes the user-defined function if it exists.
        $IfExists
    )
    
    $query = 'DROP FUNCTION [{0}].[{1}]' -f $Schema,$Name
    
    if( $IfExists )
    {
        $query = @'
        IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[{0}].[{1}]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
            {2}
'@ -f $Schema,$Name,$query
    }
    
    $op = New-Object 'Rivet.Operations.RawQueryOperation' $query
    Invoke-MigrationOperation -Operation $op
}