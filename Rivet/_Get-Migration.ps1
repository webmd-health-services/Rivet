
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
        $ConfigFilePath
    )

    Set-StrictMode -Version Latest

    function Clear-Migration
    {
        ($pushFunctionPath,'function:Pop-Migration') |
            Where-Object { Test-Path -Path $_ } |
            Remove-Item
    }

    $settings = Get-RivetConfig -Database $Database -Path $ConfigFilePath -Environment $Environment

    $settings.Databases | ForEach-Object {
        $dbName = $_.Name
        $DBScriptRoot = $_.Root
        $DBMigrationsRoot = $_.MigrationsRoot

        Get-MigrationScript -Path $_.MigrationsRoot | ForEach-Object {

            
            $m = New-Object Rivet.Migration $_.MigrationID,$_.MigrationName,$_.FullName,$dbName
            $currentOp = 'Push'

            function Invoke-Migration
            {
                param(
                    [Parameter(Mandatory=$true)]
                    [Rivet.Operations.Operation]
                    # The migration object to invoke.
                    $Operation,

                    [Parameter(ValueFromRemainingArguments=$true)]
                    $Garbage
                )

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
