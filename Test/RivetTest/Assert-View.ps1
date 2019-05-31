function Assert-View
{
    <#
    .SYNOPSIS
    Tests that a custom view exists.
    #>
    param(
        [string]
        # The schema name of the view.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the view.
        $Name,

        [string]
        # The definition of the view.
        $Definition,

        [string]
        # The view's MS_Description extended property.
        $Description
    )
    
    Set-StrictMode -Version 'Latest'

    $view = Get-View -SchemaName $SchemaName -Name $Name

    $expectedDefinition = "create view [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition
    if( (Test-Pester) )
    {
        $view | Should -Not -BeNullOrEmpty
        if( $PSBoundParameters.ContainsKey('Definition') )
        {
            $view.definition | Should -Match ([Text.RegularExpressions.Regex]::Escape($expectedDefinition))
        }

        if( $PSBoundParameters.ContainsKey('Description') )
        {
            $Description | Should -Be $view.MS_Description
        }
    }
    else
    {
        Assert-NotNull $view ('View {0}.{1} not found.' -f $SchemaName,$Name)
    
        if( $PSBoundParameters.ContainsKey('Definition') )
        {
            Assert-Match $view.definition ([Text.RegularExpressions.Regex]::Escape($expectedDefinition))
        }

        if( $PSBoundParameters.ContainsKey('Description') )
        {
            Assert-Equal $Description $view.MS_Description
        }
    }
}
