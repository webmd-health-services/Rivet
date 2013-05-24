
function Invoke-Pstep
{
    param(
        [Parameter(Mandatory=$true,ParameterSEtName='Push')]
        [Switch]
        $Push,

        [Parameter(Mandatory=$true,ParameterSEtName='Pull')]
        [Switch]
        $Pop,

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name of the migration to push/pop.
        $Name
    )

    & $PstepPath @PSBoundParameters -SqlServerName $Server -Database $DatabaseName -Path $DatabaseRoot 

}