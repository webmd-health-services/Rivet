
#Requires -Version 4
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

. (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Functions\Split-SqlBatchQuery.ps1' -Resolve)
. (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Functions\Invoke-Query.ps1' -Resolve)

Describe 'Invoke-Query.when passing command timeout' {
    New-Database $RTDatabaseName
    $Connection = New-SqlConnection
    $Connection | Add-Member -Name 'Transaction' -Value $null -MemberType NoteProperty
    $Connection.Transaction = $Connection.BeginTransaction()
    $failed = $false
    try
    {
        Invoke-Query -Query 'WAITFOR DELAY ''00:00:05''' -CommandTimeout 1
    }
    catch [Data.SqlClient.SqlException]
    {
        $failed = $true
    }
    finally
    {
        $Connection.Transaction.Rollback()
    }

    It ('should fail') {
        $failed | Should -BeTrue
    }
}

Remove-Item -Path 'function:Invoke-Query'
Remove-Item -Path 'function:Split-SqlBatchQuery'
