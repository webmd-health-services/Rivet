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

        [Parameter()]
        [string]
        # The schema name of the view.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The definition of the view.
        $Definition
    )
    
    Set-StrictMode -Version Latest

    $view = Get-SysObjects | where{$_.type -match "V" -and $_.name -match $Name}
   
    Assert-NotNull $view ('View {0}.{1} doesn''t exist.' -f $SchemaName,$Name)
    
    $od = Get-ObjectDefinition $view.object_id

    $expectedDefinition = "create view [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition
    Assert-Equal $expectedDefinition $od.'Object Definition'

}