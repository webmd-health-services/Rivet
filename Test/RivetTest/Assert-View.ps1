function Assert-View
{
    <#
    .SYNOPSIS
    Tests that a custom view exists.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the view.
        $Name,

        [string]
        # The schema name of the view.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [string]
        # The definition of the view.
        $Definition,

        [string]
        # The view's MS_Description extended property.
        $Description
    )
    
    Set-StrictMode -Version 'Latest'

    $view = Get-SysObject -SchemaName $SchemaName -Name $Name -Type 'V'
   
    Assert-NotNull $view ('View {0}.{1} not found.' -f $SchemaName,$Name)
    
    if( $PSBoundParameters.ContainsKey('Definition') )
    {
        $expectedDefinition = "create view [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition
        Assert-Match $view.definition ([Text.RegularExpressions.Regex]::Escape($expectedDefinition))
    }

    if( $PSBoundParameters.ContainsKey('Description') )
    {
        Assert-Equal $Description $view.MS_Description
    }

}