
function Assert-StoredProcedure
{
    <#
    .SYNOPSIS
    Tests that a stored procedure exists.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the stored procedure.
        $Name,

        [Parameter()]
        [string]
        # The schema name of the stored procedure.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [string]
        # The stored procedure's definition
        $Definition
    )
    
    Set-StrictMode -Version Latest

    $sp = Get-StoredProcedure -SchemaName $SchemaName -Name $Name
   
    Assert-NotNull $sp ('Stored Procedure {0}.{1} doesn''t exist.' -f $SchemaName,$Name)

    if( $PSBoundParameters.ContainsKey('Definition') )
    {    
        $expectedDefinition = "CREATE procedure [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition
        Assert-Match $sp.definition ([Text.RegularExpressions.Regex]::Escape($expectedDefinition))
    }

}