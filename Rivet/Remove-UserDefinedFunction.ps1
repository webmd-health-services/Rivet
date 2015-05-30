
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
    Remove-UserDefinedFunction -Name MyFunc -SchemaName rivet
    
    Removes the `rivet.MyFunc` user-defined function.
    
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
        $SchemaName = 'dbo'

    )
    
    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.RemoveUserDefinedFunctionOperation' $SchemaName, $Name
}