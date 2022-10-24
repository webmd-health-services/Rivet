
$Connection = New-Object Data.SqlClient.SqlConnection

$RivetSchemaName = 'rivet'
$RivetMigrationsTableName = 'Migrations'
$RivetMigrationsTableFullName = "[$($RivetSchemaName)].[$($RivetMigrationsTableName)]"
$RivetActivityTableName = 'Activity'
$rivetModuleRoot = $PSScriptRoot
$script:firstMigrationId = [Int64]'00010101000000' # 1/1/1 00:00:00

$timer = New-Object 'Diagnostics.Stopwatch'
$timerForWrites = New-Object 'Diagnostics.Stopwatch'
$timingLevel = 0

$plugins = @()

function Write-Timing
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Message,

        [Switch]
        $Indent,

        [Switch]
        $Outdent
    )

    Set-StrictMode -Version 'Latest'

    if( -not $timer.IsRunning )
    {
        $timer.Start()
    }

    if( -not $timerForWrites.IsRunning )
    {
        $timerForWrites.Start()
    }

    if( $Outdent )
    {
        $script:timingLevel -= 1
    }

    $prefix = ' ' * ($timingLevel * 2)

    function ConvertTo-DurationString
    {
        param(
            [Parameter(Mandatory,ValueFromPipeline)]
            [TimeSpan]$TimeSpan
        )

        process 
        {
            Set-StrictMode -Version 'Latest'

            $hours = ''
            if( $TimeSpan.Hours )
            {
                $hours = "$($TimeSpan.Hours.ToString())h "
            }

            $minutes = ''
            if( $TimeSpan.Minutes )
            {
                $minutes = "$($TimeSpan.Minutes.ToString('00'))m "
            }

            $seconds = ''
            if( $TimeSpan.Seconds )
            {
                $seconds = "$($TimeSpan.Seconds.ToString('00'))s "
            }

            return "$($hours)$($minutes)$($seconds)$($TimeSpan.Milliseconds.ToString('000'))ms"
        }
    }
    
    # $DebugPreference = 'Continue'

    if( $DebugPreference -eq 'Continue' )
    {
        Write-Debug -Message ('{0,17}  {1,17}  {2}{3}' -f ($timer.Elapsed | ConvertTo-DurationString),($timerForWrites.Elapsed | ConvertTo-DurationString),$prefix,$Message)
    }

    $timerForWrites.Restart()

    if( $Indent )
    {
        $script:timingLevel += 1
    }

    if( $timingLevel -lt 0 )
    {
        $timingLevel = 0
    }
}

function Test-RivetTypeDataMember
{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The type name to check.
        $TypeName,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the member to check.
        $MemberName
    )

    Set-StrictMode -Version 'Latest'

    $typeData = Get-TypeData -TypeName $TypeName
    if( -not $typeData )
    {
        # The type isn't defined or there is no extended type data on it.
        return $false
    }

    return $typeData.Members.ContainsKey( $MemberName )
}

$oldVersionLoadedMsg = 'You have an old version of Rivet loaded. Please restart your PowerShell session.'
function New-RivetObject
{
    param(
        [Parameter(Mandatory)]
        [String]$TypeName,

        [Object[]]$ArgumentList
    )

    try
    {
        return (New-Object -TypeName $TypeName -ArgumentList $ArgumentList -ErrorAction Ignore)
    }
    catch
    {
        Write-Error -Message ('Unable to find type "{0}". {1}' -f $TypeName,$oldVersionLoadedMsg) -ErrorAction Stop
    }
}

if( -not (Test-RivetTypeDataMember -TypeName 'Rivet.OperationResult' -MemberName 'MigrationID') )
{
    Update-TypeData -TypeName 'Rivet.OperationResult' -MemberType ScriptProperty -MemberName 'MigrationID' -Value { $this.Migration.ID }
}

# Added in Rivet 0.10.0
Test-RivetTypeDataMember -TypeName 'Rivet.Scale' -MemberName 'Value'

# Import functions on developer computers.
& {
    Join-Path -Path $rivetModuleRoot -ChildPath 'Functions'
    Join-Path -Path $rivetModuleRoot -ChildPath 'Functions\Columns'
    Join-Path -Path $rivetModuleRoot -ChildPath 'Functions\Operations'
} |
    Where-Object { Test-Path -Path $_ -PathType Container } |
    Get-ChildItem -Filter '*-*.ps1' |
    ForEach-Object { . $_.FullName }
