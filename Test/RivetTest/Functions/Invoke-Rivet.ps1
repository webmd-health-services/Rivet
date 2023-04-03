
function Invoke-RTRivet
{
    [CmdletBinding(SupportsShouldProcess,DefaultParameterSetName='PushByName')]
    param(
        [Parameter(Mandatory,ParameterSetName='Push')]
        [switch]$Push,

        [Parameter(Mandatory,ParameterSetName='Pop')]
        [Parameter(Mandatory,ParameterSetName='PopByName')]
        [Parameter(Mandatory,ParameterSetName='PopByCount')]
        [Parameter(Mandatory,ParameterSetName='PopAll')]
        [switch]$Pop,
        
        [Parameter(Position=1,ParameterSetName='Push')]
        [Parameter(Mandatory,Position=0,ParameterSetName='PushByName')]
        [Parameter(Mandatory,Position=1,ParameterSetName='PopByName')]
        # The name of the migration to push/pop.
        [String]$Name,

        [Parameter(Mandatory,Position=1,ParameterSetName='PopByCount')]
        [int]$Count,

        [Parameter(Mandatory,ParameterSetName='PopAll')]
        [switch]$All,

        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='PopByName')]
        [Parameter(ParameterSetName='PopByCount')]
        [Parameter(ParameterSetName='PopAll')]
        [Parameter(ParameterSetName='DropDatabase')]
        [Parameter(ParameterSetName='Checkpoint')]
        [switch]$Force,

        [Parameter(ParameterSetName='Redo')]
        [switch]$Redo,

        [String[]]$Database,

        [String]$ConfigFilePath,

        [Parameter(ParameterSetName='DropDatabase')]
        [Switch]
        # Drops the database(s) for the current environment when given. User will be prompted for confirmation when used.
        $DropDatabase,

        [Parameter(ParameterSetName='Checkpoint')]
        [Switch]
        # Checkpoints the current state of the database so that it can be re-created.
        $Checkpoint,

        [Parameter(ParameterSetName='InitializeSchema')]
        [Switch]
        # Initializes the database, including baseline schema. Use the -Checkpoint switch to create a database baseline.
        $InitializeSchema
    )
    
    Set-StrictMode -Version Latest
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if( $PSCmdlet.ParameterSetName -eq 'PushByName' )
    {
        $PSBoundParameters['Push'] = $Push = $true
    }

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

    try
    {
        Invoke-Rivet @PSBoundParameters @customParams
    }
    catch
    {
        $script:RTLastMigrationFailed = $true
        if( $ErrorActionPreference -ne [Management.Automation.ActionPreference]::SilentlyContinue -and `
            $ErrorActionPreference -ne [Management.Automation.ActionPreference]::Ignore )
        {
            $_ | Out-String | Write-Host -ForegroundColor Red
        }
    }
}

Set-Alias -Name 'WhenMigrating' -Value 'Invoke-RTRivet'
