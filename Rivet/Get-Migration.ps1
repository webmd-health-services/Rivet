
function Get-Migration
{
    <#
    .SYNOPSIS
    Gets the migrations for a given database.

    .DESCRIPTION
    This function exposes Rivet's internal migration objects so you can do cool things with them.  You're welcome.  Enjoy!

    Each object returned represents one migration, and includes properties for the push and pop operations in that migration.

    .OUTPUTS
    Rivet.Migration.

    .EXAMPLE
    Get-Migration

    Returns `Rivet.Migration` objects for each migration in each database.

    .EXAMPLE
    Get-Migration -Database StarWars

    Returns `Rivet.Migration` objects for each migration in the `StarWars` database.
    #>
    [CmdletBinding(DefaultParameterSetName='Internal')]
    param(
        [Parameter(ParameterSetName='External')]
        [string[]]
        $Database,

        [Parameter(ParameterSetName='External')]
        [string]
        $Environment,

        [Parameter(ParameterSetName='External')]
        [string]
        $ConfigFilePath,

        [Parameter(ParameterSetName='Internal')]
        [string[]]
        # The path to a specific migration or directory of migrations.
        $Path,

        [string[]]
        # A list of migrations to include. Only migrations that match are returned.  Wildcards permitted.
        $Include,

        [string[]]
        # Migrations to exclude.  Wildcards permitted.
        $Exclude,

        [DateTime]
        # Only get migrations before this date.  Default is all.
        $Before,

        [DateTime]
        # Only get migrations after this date.  Default is all.
        $After
    )

    Set-StrictMode -Version Latest

    function Clear-Migration
    {
        ('function:Push-Migration','function:Pop-Migration') |
            Where-Object { Test-Path -Path $_ } |
            Remove-Item
    }

    filter ConvertTo-Migration
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
            [string]
            # The path to a migration.
            $Path
        )

        Set-StrictMode -Version 'Latest'

    }

    Clear-Migration

    Invoke-Command -ScriptBlock {
            if( $PSCmdlet.ParameterSetName -eq 'External' )
            {
                $getRivetConfigParams = @{ }
                if( $Database )
                {
                    $getRivetConfigParams['Database'] = $Database
                }

                if( $ConfigFilePath )
                {
                    $getRivetConfigParams['ConfigFilePath'] = $ConfigFilePath
                }

                if( $Environment )
                {
                    $getRivetConfigParams['Environment'] = $Environment
                }

                $settings = Get-RivetConfig -Database $Database -Path $ConfigFilePath -Environment $Environment
                if( $settings.PluginsRoot )
                {
                    Import-Plugin -Path $settings.PluginsRoot
                }
                
                $settings.Databases | Select-Object -ExpandProperty 'MigrationsRoot'
            }
            else
            {
                $Path
            }
        } | 
        ForEach-Object {
            if( (Test-Path -Path $_ -PathType Container) )
            {
                Get-ChildItem -Path $_ -Filter '*_*.ps1'
            }
            elseif( (Test-Path -Path $_ -PathType Leaf) )
            {
                Get-Item -Path
            }
            else
            {
                #Write-Error ('Migration path ''{0}'' not found.' -f $_)
            }
        
        } | 
        Where-Object {
            $script = $_
            if( -not ($PSBoundParameters.ContainsKey( 'Include' )) )
            {
                return $true
            }

            $Include | Where-Object { $script.BaseName -like $_ }
        } |
        Where-Object { 
            $script = $_

            if( -not ($PSBoundParameters.ContainsKey( 'Exclude' )) )
            {
                return $true
            }

            $foundMatch = $Exclude | Where-Object { $script.BaseName -like $_ }
            return -not $foundMatch
        } |
        ForEach-Object {
            if( $_.BaseName -notmatch '^(\d{14})_(.+)' )
            {
                Write-Error ('Migration {0} has invalid name.  Must be of the form `YYYYmmddhhMMss_MigrationName.ps1' -f $_.FullName)
                return
            }
        
            $id = [UInt64]$matches[1]
            $name = $matches[2]
        
            $_ | 
                Add-Member -MemberType NoteProperty -Name 'MigrationID' -Value $id -PassThru |
                Add-Member -MemberType NoteProperty -Name 'MigrationName' -Value $name -PassThru
        } |
        Where-Object {
            if( $PSBoundParameters.ContainsKey( 'Before' ) )
            {
                $beforeTimestamp = [uint64]$Before.ToString('yyyyMMddHHmmss')
                if( $_.MigrationID -gt $beforeTimestamp )
                {
                    return $false
                }
            }

            if( $PSBoundParameters.ContainsKey( 'After' ) )
            {
                $afterTimestamp = [uint64]$After.ToString('yyyyMMddHHmmss')
                if( $_.MigrationID -lt $afterTimestamp )
                {
                    return $false
                }
            }
            return $true
        } |
        ForEach-Object {
            $dbName = Split-Path -Parent -Path $_.FullName
            $dbName = Split-Path -Parent -Path $dbName
            $dbName = Split-Path -Leaf -Path $dbName

            $m = New-Object 'Rivet.Migration' $_.MigrationID,$_.MigrationName,$_.FullName,$dbName
            $currentOp = 'Push'

            filter Add-Operation
            {
                param(
                    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
                    [object]
                    # The migration object to invoke.
                    $Operation,

                    [Parameter(ParameterSetName='Push',Mandatory=$true)]
                    [Collections.Generic.IList[Rivet.Operation]]
                    [AllowEmptyCollection()]
                    $OperationsList,

                    [Parameter(ParameterSetName='Pop',Mandatory=$true)]
                    [Switch]
                    $Pop
                )

                Set-StrictMode -Version 'Latest'

                $Operation |
                    Where-Object { $_ -is [Rivet.Operation] } |
                    ForEach-Object {
                        if( (Test-Path -Path 'function:Start-MigrationOperation') )
                        {
                            Start-MigrationOperation -Operation $_
                        }

                        $_

                        if( (Test-Path -Path 'function:Complete-MigrationOperation') )
                        {
                            Complete-MigrationOperation -Operation $_
                        }
                    } |
                    Where-Object { $_ -is [Rivet.Operation] } |
                    ForEach-Object { $OperationsList.Add( $_ ) } |
                    Out-Null
            }

            $DBMigrationsRoot = Split-Path -Parent -Path $_.FullName

            . $_.FullName

            try
            {
                if( (Test-Path -Path 'function:Push-Migration') )
                {
                    Push-Migration | Add-Operation -OperationsList $m.PushOperations
                }
                else
                {
                    Write-Warning ('{0} migration''s ''Push-Migration'' function not found.' -f $_.FullName)
                }
                
                $currentOp = 'Pop'
                if( (Test-Path -Path 'function:Pop-Migration') )
                {
                    Pop-Migration | Add-Operation  -OperationsList $m.PopOperations
                }
                else
                {
                    Write-Warning ('{0} migration''s ''Pop-Migration'' function not found.' -f $_.FullName)
                }

                $m
            }
            catch
            {
                Write-RivetError -Message ('Loading migration ''{0}'' failed' -f $m.Path) `
                                 -CategoryInfo $_.CategoryInfo.Category `
                                 -ErrorID $_.FullyQualifiedErrorID `
                                 -Exception $_.Exception `
                                 -CallStack ($_.ScriptStackTrace) 
            }
            finally
            {
                Clear-Migration
            }
        }
}
