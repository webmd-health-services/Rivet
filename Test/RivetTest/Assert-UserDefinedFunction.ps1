function Assert-UserDefinedFunction
{
    <#
    .SYNOPSIS
    Tests that a user-defined function exists.
    #>
    param(
        [string]
        # The schema name of the user defined function.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the user defined function.
        $Name,

        [string]
        # Asserts the definition of the function.
        $Definition
    )
    
    Set-StrictMode -Version Latest

    $udf = Get-UserDefinedFunction -SchemaName $SchemaName -Name $Name
   
    Assert-NotNull $udf ('User Defined Function {0}.{1} not found.' -f $SchemaName,$Name)
    
    if( $PSBoundParameters.ContainsKey( 'Definition' ) )
    {
        $expectedDefinition = "create function [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition
        Assert-Match $udf.definition ([Text.RegularExpressions.Regex]::Escape( $expectedDefinition ))
    }
}