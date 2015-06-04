
function Get-Migration
{
    <#
    .SYNOPSIS
    Gets the migrations for all or specific databases.

    .DESCRIPTION
    The `Get-Migration` function returns `Rivet.Migration` objects for all the migrations in all or specific databases. With no parameters, looks in the current directory for a `rivet.json` file and returns all the migrations for all the databases based on that configuration. Use the `ConfigFilePath` to load and use a specific `rivet.json` file.

    You can return migrations from specific databases by passing those database names as values to the `Database` parameter. 

    The `Environment` parameter is used to load the correct environment-specific settings from the `rivet.json` file.

    You can filter what migrations are returned using the `Include` or `Exclude` parameters, which support wildcards, and will match any part of the migration's filename, including the ID.

    Use the `Before` and `After` parameters to return migrations whose timestamps/IDs come before and after the given dates.

    .OUTPUTS
    Rivet.Migration.

    .EXAMPLE
    Get-Migration

    Returns `Rivet.Migration` objects for each migration in each database.

    .EXAMPLE
    Get-Migration -Database StarWars

    Returns `Rivet.Migration` objects for each migration in the `StarWars` database.
    #>
    [CmdletBinding(DefaultParameterSetName='External')]
    [OutputType([Rivet.Migration])]
    param(
        [Parameter(ParameterSetName='External')]
        [string[]]
        # The database whose migrations to get.
        $Database,

        [Parameter(ParameterSetName='External')]
        [string]
        # The environment settings to use.
        $Environment,

        [Parameter(ParameterSetName='External')]
        [string]
        # The path to the rivet.json file to use. Defaults to `rivet.json` in the current directory.
        $ConfigFilePath,

        [Parameter(Mandatory=$true,ParameterSetName='Internal')]
        [Rivet.Configuration.Configuration]
        # The configuration to use.
        $Configuration,

        [Parameter(Mandatory=$true,ParameterSetName='Internal')]
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

    Clear-Migration

    if( $PSCmdlet.ParameterSetName -eq 'External' )
    {
        $getRivetConfigParams = @{ }
        if( $Database )
        {
            $getRivetConfigParams['Database'] = $Database
        }

        if( $ConfigFilePath )
        {
            $getRivetConfigParams['Path'] = $ConfigFilePath
        }

        if( $Environment )
        {
            $getRivetConfigParams['Environment'] = $Environment
        }

        $Configuration = Get-RivetConfig @getRivetConfigParams
        if( -not $Configuration )
        {
            return
        }
    }

    if( $Configuration.PluginsRoot )
    {
        Import-Plugin -Path $settings.PluginsRoot
    }
                
    Invoke-Command -ScriptBlock {
            if( $PSCmdlet.ParameterSetName -eq 'Internal' )
            {
                return $Path
            }

            $Configuration.Databases | Select-Object -ExpandProperty 'MigrationsRoot'
        } | 
        ForEach-Object {
            Write-Verbose $_ 
            if( (Test-Path -Path $_ -PathType Container) )
            {
                Get-ChildItem -Path $_ -Filter '*_*.ps1'
            }
            elseif( (Test-Path -Path $_ -PathType Leaf) )
            {
                Get-Item -Path $_
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
                    [Collections.Generic.List[Rivet.Operation]]
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
        } | 
        # TODO: Write a test for this, i.e. make sure we protect our selves from scripts that return shit.
        Where-Object { $_ -is [Rivet.Migration] }
}
