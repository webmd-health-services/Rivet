
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:migration1 = $null
    $script:migration2 = $null
    $script:migration3 = $null
    $script:migration4 = $null
}

Describe 'Pop-Migration' {
    BeforeEach {
        Start-RivetTest
        $Global:Error.Clear()

        $script:migration1 = @'
    function Push-Migration
    {
        Add-Table 'Migration1' { int ID -Identity }
    }
    function Pop-Migration
    {
        Remove-Table 'Migration1'
    }
'@ | New-TestMigration -Name 'Migration1'

        $script:migration2 = @'
    function Push-Migration
    {
        Add-Table 'Migration2' { int ID -Identity }
    }
    function Pop-Migration
    {
        Remove-Table 'Migration2'
    }
'@ | New-TestMigration -Name 'Migration2'

        $script:migration3 = @'
    function Push-Migration
    {
        Add-Table 'Migration3' { int ID -Identity }
    }
    function Pop-Migration
    {
        Remove-Table 'Migration3'
    }
'@ | New-TestMigration -Name 'Migration3'

        $script:migration4 = @'
    function Push-Migration
    {
        Add-Table 'Migration4' { int ID -Identity }
    }
    function Pop-Migration
    {
        Remove-Table 'Migration4'
    }
'@ | New-TestMigration -Name 'Migration4'

        Invoke-RTRivet -Push

        $expectedCount = Measure-MigrationScript
        (Measure-Migration) | Should -Be $expectedCount
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should pop all migrations' {
        $migrationCount = Measure-Migration
        ($migrationCount -gt 1) | Should -BeTrue

        Invoke-RTRivet -Pop $migrationCount

        (Measure-Migration) | Should -Be 0

        Get-MigrationScript | ForEach-Object {

            $id,$name = $_.BaseName -split '_'

            (Test-Table -Name $name) | Should -BeFalse
        }
    }

    It 'should write to activity table on pop' {
        $migrationCount = Measure-Migration
        ($migrationCount -gt 1) | Should -BeTrue

        Invoke-RTRivet -Pop

        (Measure-Migration) | Should -Be ($migrationCount-1)

        $rows = Get-ActivityInfo

        $rows[-1].Operation | Should -Be 'Pop'
        $rows[-1].Name | Should -Be 'Migration4'
    }

    It 'should pop specific number of database migrations' {
        $rivetCount = Measure-Migration
        ($rivetCount -gt 1) | Should -BeTrue

        Invoke-RTRivet -Pop 2

        (Measure-Migration) | Should -Be ($rivetCount - 2)
    }

    It 'should pop one migration by default' {
        $totalMigrations = Measure-Migration

        Invoke-RTRivet -Pop

        (Measure-Migration) | Should -Be ($totalMigrations - 1)

        $firstMigration = Get-MigrationScript | Select-Object -First 1

        $id,$name = $firstMigration.BaseName -split '_'
        (Test-Table -Name $name) | Should -BeTrue
    }

    It 'should not re pop migrations' {
        $originalMigrationCount = Measure-Migration
        Invoke-RTRivet -Pop
        $Global:Error.Count | Should -Be 0
        (Measure-Migration) | Should -Be ($originalMigrationCount - 1)

        Invoke-RTRivet -Pop 2
        $Global:Error.Count | Should -Be 0
        (Measure-Migration) | Should -Be ($originalMigrationCount - 2)

        Invoke-RTRivet -Pop 2
        $Global:Error.Count | Should -Be 0
        (Measure-Migration) | Should -Be ($originalMigrationCount - 2)
    }

    It 'should support popping more than available migrations' {
        $migrationCount = Measure-Migration
        Invoke-RTRivet -Pop ($migrationCount * 2)
        $Global:Error.Count | Should -Be 0
        (Measure-Migration) | Should -Be 0
    }


    It 'should stop popping migrations if one gives an error' {
        $migrationFileInfo = @'
    function Push-Migration
    {
        Add-Table 'Migration5' {
            int 'ID' -Identity
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Migration38'
    }
'@ | New-TestMigration -Name 'PopFails'

        try
        {
            Invoke-RTRivet -Push
            $Global:Error.Count | Should -Be 0

            { Invoke-RTRivet -Pop (Measure-Migration) } | Should -Throw '*cannot drop the table ''dbo.Migration38''*'

            $Global:Error.Count | Should -BeGreaterThan 0

            (Test-Table -Name 'Migration5') | Should -BeTrue
            (Test-Table -Name 'Migration4') | Should -BeTrue
            (Test-Table -Name 'Migration3') | Should -BeTrue
            (Test-Table -Name 'Migration2') | Should -BeTrue
            (Test-Table -Name 'Migration1') | Should -BeTrue
        }
        finally
        {
            @'
    function Push-Migration
    {
        Add-Table 'Migration5' {
            int 'ID' -Identity
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Migration5'
    }
'@ | Set-Content -Path $migrationFileInfo
        }
    }

    It 'should pop by name' {
        Invoke-RTRivet -Pop 'Migration1'

        (Test-Table -Name 'Migration4') | Should -BeTrue
        (Test-Table -Name 'Migration3') | Should -BeTrue
        (Test-Table -Name 'Migration2') | Should -BeTrue
        (Test-Table -Name 'Migration1') | Should -BeFalse
    }

    It 'should pop by name with wildcard' {
        Invoke-RTRivet -Pop 'Migration*'

        (Test-Table -Name 'Migration4') | Should -BeFalse
        (Test-Table -Name 'Migration3') | Should -BeFalse
        (Test-Table -Name 'Migration2') | Should -BeFalse
        (Test-Table -Name 'Migration1') | Should -BeFalse
    }


    It 'should pop by name with no match' {
        { Invoke-RTRivet -Pop 'Blah' } | Should -Throw '*Blah*does not exist*'

        (Test-Table -Name 'Migration4') | Should -BeTrue
        (Test-Table -Name 'Migration3') | Should -BeTrue
        (Test-Table -Name 'Migration2') | Should -BeTrue
        (Test-Table -Name 'Migration1') | Should -BeTrue
    }

    It 'should pop by ID' {
        $name = $script:migration1.BaseName.Substring(0,14)
        Invoke-RTRivet -Pop $name
        Assert-Table -Name 'Migration4'
        Assert-Table -Name 'Migration3'
        Assert-Table -Name 'Migration2'
        (Test-Table -Name 'Migration1') | Should -BeFalse
    }

    It 'should pop by ID with wildcard' {
        $name = '{0}*' -f $RTTimestamp.ToString().Substring(0,8)
        Invoke-RTRivet -Pop $name
        (Test-Table -Name 'Migration4') | Should -BeFalse
        (Test-Table -Name 'Migration3') | Should -BeFalse
        (Test-Table -Name 'Migration2') | Should -BeFalse
        (Test-Table -Name 'Migration1') | Should -BeFalse
    }

    It 'should pop all' {
        Invoke-RTRivet -Pop -All
        (Test-Table -Name 'Migration4') | Should -BeFalse
        (Test-Table -Name 'Migration3') | Should -BeFalse
        (Test-Table -Name 'Migration2') | Should -BeFalse
        (Test-Table -Name 'Migration1') | Should -BeFalse
    }

    It 'should confirm popping anothers migration' {
        Invoke-RivetTestQuery -Query 'update [rivet].[Migrations] set Who = ''LittleLionMan'''

        Invoke-RTRivet -Pop -All -Force
        (Test-Table 'Migration4') | Should -BeFalse
        (Test-Table 'Migration3') | Should -BeFalse
        (Test-Table 'Migration2') | Should -BeFalse
        (Test-Table 'Migration1') | Should -BeFalse
    }

    It 'should confirm popping old migrations' {
        Invoke-RivetTestQuery -Query 'update [rivet].[Migrations] set AtUtc = dateadd(minute, -21, AtUtc)'

        Invoke-RTRivet -Pop -All -Force
        (Test-Table 'Migration4') | Should -BeFalse
        (Test-Table 'Migration3') | Should -BeFalse
        (Test-Table 'Migration2') | Should -BeFalse
        (Test-Table 'Migration1') | Should -BeFalse
    }
}
