 function Update-UserDefinedFunction
{
    <#
    .SYNOPSIS
    Updates an existing user-defined function.

    .DESCRIPTION
    Updates an existing user-defined function.

    .EXAMPLE
    Update-UserDefinedFunction -SchemaName 'rivet' 'One' 'returns tinyint begin return 1 end'

    Updates a user-defined function to return the number 1.
    #>    

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the stored procedure.
        $Name,
        
        [Parameter()]
        [string]
        # The schema name of the stored procedure.  Defaults to `dbo`.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The store procedure's definition.
        $Definition
    )
    
    $op = New-Object Rivet.Operations.UpdateUserDefinedFunctionOperation $SchemaName,$Name,$Definition
    Write-Host(' ={0}.{1}' -f $SchemaName,$Name)
    Invoke-MigrationOperation -Operation $op
}