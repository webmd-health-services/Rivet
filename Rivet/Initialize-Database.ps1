
function Initialize-Database
{
    <#
    .SYNOPSIS
    Intializes the database so that it can be migrated by Rivet.
    #>
    [CmdletBinding()]
    param(
    )

    Set-StrictMode -Version 'Latest'

    $who = ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME);
    $migrationsPath = Join-Path -Path $PSScriptRoot -ChildPath 'Migrations'
    $migrations = Get-MigrationScript -Path $migrationsPath

    foreach( $migrationInfo in $migrations )
    {

        try
        {
            if( (Test-Migration -ID $migrationInfo.MigrationID -ErrorAction Ignore) )
            {
                continue
            }
        }
        catch
        {
            if( $Global:Error.Count -gt 0 )
            {
                $Global:Error.RemoveAt(0)
            }
        }

        . $migrationInfo.FullName

        $Connection.Transaction = $Connection.BeginTransaction()
        try
        {
            Push-Migration
            $parameters = @{
                                ID = [int64]$migrationInfo.MigrationID; 
                                Name = $migrationInfo.MigrationName;
                                Who = $who;
                                ComputerName = $env:COMPUTERNAME;
                            }

            $query = "exec [rivet].[InsertMigration] @ID = @ID, @Name = @Name, @Who = @Who, @ComputerName = @ComputerName"

            Invoke-Query -Query $query -NonQuery -Parameter $parameters | Out-Null
            $Connection.Transaction.Commit()
        }
        catch
        {
            $Connection.Transaction.Rollback()

            if( $_.Exception -isnot [ApplicationException] )
            {
                Write-RivetError -Message ('Internal Rivet Migration {0} failed' -f $migrationInfo.FullName) -CategoryInfo $_.CategoryInfo.Category -ErrorID $_.FullyQualifiedErrorID -Exception $_.Exception -CallStack ($_.ScriptStackTrace)
            }            
        }
    }
}
