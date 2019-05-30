
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
        $Definition,

        [string]
        $DatabaseName
    )
    
    Set-StrictMode -Version Latest

    $sp = Get-StoredProcedure -SchemaName $SchemaName -Name $Name -DatabaseName $DatabaseName

    $expectedDefinition = "CREATE procedure [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition

    if( (Test-Path -Path 'TestDrive:') )
    {
        $sp | Should -Not -BeNullOrEmpty

        if( $PSBoundParameters.ContainsKey('Definition') )
        {    
            $sp.definition | Should -Match ([Text.RegularExpressions.Regex]::Escape($expectedDefinition))
        }
    }
    else
    {
        Assert-NotNull $sp ('Stored Procedure {0}.{1} doesn''t exist.' -f $SchemaName,$Name)

        if( $PSBoundParameters.ContainsKey('Definition') )
        {    
            Assert-Match $sp.definition ([Text.RegularExpressions.Regex]::Escape($expectedDefinition))
        }
    }
}
