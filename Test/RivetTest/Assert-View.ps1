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
    
    Set-StrictMode -Version Latest

    $view = Get-SysObject -Name $Name -Type 'V'
   
    Assert-NotNull $view ('View {0}.{1} doesn''t exist.' -f $SchemaName,$Name)
    
    if( $PSBoundParameters.ContainsKey('Definition') )
    {
        $od = Get-ObjectDefinition $view.object_id
        $expectedDefinition = "create view [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition
        Assert-Equal $expectedDefinition $od.'Object Definition'
    }

    if( $PSBoundParameters.ContainsKey('Description') )
    {
        Assert-Equal $Description $view.MS_Description
    }

}