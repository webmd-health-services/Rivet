
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
    [CmdletBinding()]
    param(
        [string[]]
        $Database,

        [string]
        $Environment,

        [string]
        $ConfigFilePath,

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

    $getMigrationScriptParams = @{ }
    @( 'Exclude', 'Include', 'Before', 'After' ) |
        Where-Object { $PSBoundParameters.ContainsKey( $_ ) } |
        ForEach-Object { $getMigrationScriptParams.$_ = Get-Variable -Name $_ -ValueOnly }

    $settings = Get-RivetConfig -Database $Database -Path $ConfigFilePath -Environment $Environment

    if( $settings.PluginsRoot )
    {
        Import-Plugin -Path $settings.PluginsRoot
    }

    $settings.Databases | ForEach-Object {
        $dbName = $_.Name
        $DBScriptRoot = $_.Root
        $DBMigrationsRoot = $_.MigrationsRoot

        Get-MigrationScript -Path $_.MigrationsRoot @getMigrationScriptParams | ForEach-Object {

            
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
                    [Collections.Generic.IList[Rivet.Operations.Operation]]
                    [AllowEmptyCollection()]
                    $OperationsList,

                    [Parameter(ParameterSetName='Pop',Mandatory=$true)]
                    [Switch]
                    $Pop
                )

                Set-StrictMode -Version 'Latest'

                $Operation |
                    Where-Object { $_ -is [Rivet.Operations.Operation] } |
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
                    Where-Object { $_ -is [Rivet.Operations.Operation] } |
                    ForEach-Object { $OperationsList.Add( $_ ) } |
                    Out-Null
            }

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
            finally
            {
                Clear-Migration
            }
        }
    }
}
