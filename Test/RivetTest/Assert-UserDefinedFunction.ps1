function Assert-UserDefinedFunction
{
    <#
    .SYNOPSIS
    Tests that a user-defined function exists.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the user defined function.
        $Name,

        [Parameter()]
        [string]
        # The schema name of the user defined function.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The definition of the user defined function
        $Definition
    )
    
    Set-StrictMode -Version Latest

    $udf = Get-SysObjects | where{$_.type -match "FN" -and $_.name -match $Name}
   
    Assert-NotNull $udf ('User Defined Function {0}.{1} doesn''t exist.' -f $SchemaName,$Name)
    
    $od = Get-ObjectDefinition $udf.object_id

    $expectedDefinition = "create function [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition
    Assert-Equal $expectedDefinition $od.'Object Definition'

}