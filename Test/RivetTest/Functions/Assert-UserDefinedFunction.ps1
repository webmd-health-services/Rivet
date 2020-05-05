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

    $expectedDefinition = "create function [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition

    if( (Test-Pester) )
    {
        $udf | Should -Not -BeNullOrEmpty ('User Defined Function {0}.{1} not found.' -f $SchemaName,$Name)
    
        if( $PSBoundParameters.ContainsKey( 'Definition' ) )
        {
            $udf.definition | Should -Match ([Text.RegularExpressions.Regex]::Escape( $expectedDefinition ))
        }
    }
    else
    {
        Assert-NotNull $udf ('User Defined Function {0}.{1} not found.' -f $SchemaName,$Name)
    
        if( $PSBoundParameters.ContainsKey( 'Definition' ) )
        {
            Assert-Match $udf.definition ([Text.RegularExpressions.Regex]::Escape( $expectedDefinition ))
        }
    }
}
