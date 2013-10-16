
function New-Migration
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        # The migration contents to output.
        $InputObject,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the migration.
        $Name
    )

    $rivetPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Rivet\rivet.ps1' -Resolve
    $migration = & $rivetPath -New -Name $Name -Database $RTDatabaseName -ConfigFilePath $RTConfigFilePath
    $InputObject | Set-Content -Path $migration
    $migration
}