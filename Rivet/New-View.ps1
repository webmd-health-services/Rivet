 function New-ViewOperation
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the view.
        $Name,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The schema name of the view.  Defaults to `dbo`.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The definition of the view.
        $Definition
    )
    
    $op = New-Object Rivet.Operations.NewViewOperation $SchemaName,$Name,$Definition
    Write-Host(' +[{0}].[{1}]' -f $SchemaName,$Name)
    Invoke-MigrationOperation -Operation $op
}