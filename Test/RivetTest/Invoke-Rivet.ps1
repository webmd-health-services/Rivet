
function Invoke-Rivet
{
    param(
        [Parameter(Mandatory=$true,ParameterSEtName='Push')]
        [Switch]
        $Push,

        [Parameter(Position=1,ParameterSetName='Push')]
        [string]
        # The name of the migration to push/pop.
        $Name,

        [Parameter(Mandatory=$true,ParameterSetName='Pop')]
        [Switch]
        $Pop,
        
        [Parameter(Position=1,ParameterSetName='Pop')]
        [UInt32]
        $Count = 1,

        [Parameter(ParameterSetName='PopAll')]
        [Switch]
        $Force,

        [Parameter(ParameterSetName='Redo')]
        [Switch]
        $Redo,

        [string[]]
        $Database,

        [string]
        $ConfigFilePath
    )
    
    Set-StrictMode -Version Latest

    $customParams = @{ }
    if( -not $Database )
    {
        $customParams.Database = $RTDatabaseName
    }

    if( -not $ConfigFilePath )
    {
        $customParams.ConfigFilePath = $RTConfigFilePath
    }

    $parms = $PSBoundParameters

    <#
    Write-Host -Foregroundcolor black $PSCmdlet.ParameterSetName
    Write-Host -Foregroundcolor blue $RTRivetPath
    Write-Host -Foregroundcolor red @PSBoundParameters
    Write-Host -Foregroundcolor green @customParams
    #>

    & $RTRivetPath @PSBoundParameters @customParams

}