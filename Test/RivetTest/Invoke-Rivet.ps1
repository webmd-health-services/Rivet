
function Invoke-RTRivet
{
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [Parameter(Mandatory=$true,ParameterSEtName='Push')]
        [Switch]
        $Push,

        [Parameter(Mandatory=$true,ParameterSetName='Pop')]
        [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
        [Parameter(Mandatory=$true,ParameterSetName='PopByCount')]
        [Parameter(Mandatory=$true,ParameterSetName='PopAll')]
        [Switch]
        $Pop,
        
        [Parameter(Position=1,ParameterSetName='Push')]
        [Parameter(Mandatory=$true,Position=1,ParameterSetName='PopByName')]
        [string]
        # The name of the migration to push/pop.
        $Name,

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='PopByCount')]
        [int]
        $Count = 1,

        [Parameter(Mandatory=$true,ParameterSetName='PopAll')]
        [Switch]
        $All,

        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='PopByName')]
        [Parameter(ParameterSetName='PopByCount')]
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
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $customParams = @{ }
    if( -not $Database )
    {
        $customParams.Database = $RTDatabaseName
    }

    if( -not $ConfigFilePath )
    {
        $customParams.ConfigFilePath = $RTConfigFilePath
    }

    <#
    $parms = $PSBoundParameters
    Write-Host -Foregroundcolor black $PSCmdlet.ParameterSetName
    Write-Host -Foregroundcolor blue $RTRivetPath
    Write-Host -Foregroundcolor red @PSBoundParameters
    Write-Host -Foregroundcolor green @customParams
    #>

    Invoke-Rivet @PSBoundParameters @customParams

}
