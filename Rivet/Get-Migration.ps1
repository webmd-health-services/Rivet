
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
        ($pushFunctionPath,'function:Pop-Migration') |
            Where-Object { Test-Path -Path $_ } |
            Remove-Item
    }

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

            function Invoke-MigrationOperation
            {
                param(
                    [Parameter(Mandatory=$true)]
                    [Rivet.Operations.Operation]
                    # The migration object to invoke.
                    $Operation,

                    [Parameter(ValueFromRemainingArguments=$true)]
                    $Garbage
                )

                if( (Test-Path -Path 'function:Start-MigrationOperation') )
                {
                    # Protect ourself from poorly written plug-ins that return things.
                    $null = Start-MigrationOperation -Operation $Operation
                }

                switch ($currentOp)
                {
                    'Push'
                    {
                        $m.PushOperations.Add( $Operation )
                    }
                    'Pop'
                    {
                        $m.PopOperations.Add( $Operation )
                    }
                }

                if( (Test-Path -Path 'function:Complete-MigrationOperation') )
                {
                    # Protect ourself from poorly written plug-ins that return things.
                    $null = Complete-MigrationOperation -Operation $Operation
                }

            }

            . $_.FullName

            $currentOp = 'Push'
            Push-Migration

            $currentOp = 'Pop'
            Pop-Migration

            $m

        }
    }
}
