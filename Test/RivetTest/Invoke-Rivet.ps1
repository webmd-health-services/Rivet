
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
        $Count,

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
    & $RTRivetPath @PSBoundParameters @customParams

}