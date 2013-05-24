
function Invoke-Pstep
{
    param(
        [Parameter(Mandatory=$true,ParameterSEtName='Push')]
        [Switch]
        $Push,

        [Parameter(Mandatory=$true,ParameterSEtName='Pull')]
        [Switch]
        $Pull
    )

    & $PstepPath @PSBoundParameters -SqlServerName $Server -Database $DatabaseName -Path $DatabaseRoot 

}