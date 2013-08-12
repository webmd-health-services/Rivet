function Get-Migration
{
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
