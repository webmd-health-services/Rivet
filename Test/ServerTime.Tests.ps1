
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'ServerTime' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'past present future' {
        $createdAt = Invoke-RivetTestQuery -Query 'select getutcdate()' -AsScalar

        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTime2 'id' -Precision 6
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTime2Column'

        Invoke-RTRivet -Push 'CreateDateTime2Column'

        $migrationRow = Get-MigrationInfo -Name 'CreateDateTime2Column'

        Write-Verbose ("Time Variance: {0}" -f ($migrationRow.AtUTC - $createdAt))
        Write-Verbose "300 ms variance is allowed"
        ($migrationRow.AtUTC.AddMilliseconds(300) -gt $createdAt) | Should -BeTrue


    }
}
