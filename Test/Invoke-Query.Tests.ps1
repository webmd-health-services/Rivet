
#Requires -Version 4
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Invoke-Query' {
    It 'can customize command timeout' {
        New-Database $RTDatabaseName
        $failed = $false
        try
        {
            InModuleScope -ModuleName 'Rivet' {
                $Connection = New-SqlConnection
                $Connection | Add-Member -Name 'Transaction' -Value $null -MemberType NoteProperty
                $Connection.Transaction = $Connection.BeginTransaction()
                try
                {
                    Invoke-Query -Query 'WAITFOR DELAY ''00:00:05''' -CommandTimeout 1
                }
                finally
                {
                    $Connection.Transaction.Rollback()
                }
            }
        }
        catch [Data.SqlClient.SqlException]
        {
            $failed = $true
        }

        $failed | Should -BeTrue
    }
}
