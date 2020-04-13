
$Connection = New-Object Data.SqlClient.SqlConnection

$RivetSchemaName = 'rivet'
$RivetMigrationsTableName = 'Migrations'
$RivetMigrationsTableFullName = '{0}.{1}' -f $RivetSchemaName,$RivetMigrationsTableName
$RivetActivityTableName = 'Activity'

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
    
    $DebugPreference = 'Continue'

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
New-RivetObject -TypeName 'Rivet.Scale' -ArgumentList '1' | Out-Null

$functionRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Functions' -Resolve
$columnRoot = Join-Path -Path $functionRoot -ChildPath 'Columns' -Resolve
$operationsRoot = Join-Path -Path $functionRoot -ChildPath 'Operations' -Resolve
@(
    $functionRoot,
    $operationsRoot,
    $columnRoot
) | 
    Get-ChildItem -Filter '*-*.ps1' |
    Where-Object { $_.BaseName -ne 'Export-Row' } |
    ForEach-Object { . $_.FullName }

$privateFunctions = @{
                        'Connect-Database' = $true;
                        'Convert-FileInfoToMigration' = $true;
                        'Disable-ForeignKey' = $true;
                        'Disconnect-Database' = $true;
                        'Enable-ForeignKey' = $true;
                        'Get-MigrationFile' = $true;
                        'Initialize-Database' = $true;
                        'Invoke-MigrationOperation' = $true;
                        'Invoke-Query' = $true;
                        'New-MigrationObject' = $true;
                        'Split-SqlBatchQuery' = $true;
                        'Test-Migration' = $true;
                        'Update-Database' = $true;
                        'Use-CallerPreference' = $true;
                        'Write-RivetError' = $true;
                     }
$publicFunctions = Invoke-Command -ScriptBlock {
                                                     @(
                                                            'Get-Migration',
                                                            'Get-RivetConfig',
                                                            'Invoke-Rivet'
                                                     )

                                                     Get-ChildItem -Path $operationsRoot,$functionRoot,$columnRoot -Filter '*.ps1' |
                                                        Select-Object -ExpandProperty 'BaseName'

                                               } |
                        Where-Object { -not $privateFunctions.ContainsKey( $_ ) }

Export-ModuleMember -Function $publicFunctions -Alias '*' -Cmdlet '*'
