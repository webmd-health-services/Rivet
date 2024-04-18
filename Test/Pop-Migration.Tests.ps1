
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    Remove-Item -Path 'alias:GivenMigration'
    Remove-Item -Path 'alias:ThenTable'

    $script:testDirPath = $null
    $script:testNum = 0
    $script:rivetJsonPath = $null
    $script:dbName = 'Pop-Migration'

    $script:migration1 = $null
    $script:migration2 = $null
    $script:migration3 = $null
    $script:migration4 = $null

    $script:migrationCount = 0

    function GivenMigration
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [Parameter(Mandatory, Position=1)]
            [String] $WithContent
        )

        $WithContent | New-TestMigration -Name $Named -ConfigFilePath $script:rivetJsonPath -DatabaseName $script:dbName
    }

    function ThenMigrationsTable
    {
        [CmdletBinding()]
        param(
            [UInt32] $HasCount,

            [switch] $IsNotEmpty,

            [switch] $IsEmpty,

            [UInt32] $Lost
        )

        $count = Measure-Migration -InDatabase $script:dbName

        if ($PSBoundParameters.ContainsKey('HasCount'))
        {
            $count | Should -Be $HasCount
        }

        if ($PSBoundParameters.ContainsKey('IsNotEmpty'))
        {
            $count | Should -BeGreaterThan 0
        }

        if ($PSBoundParameters.ContainsKey('IsEmpty'))
        {
            $count | Should -Be 0
        }

        if ($PSBoundParameters.ContainsKey('Lost'))
        {
            $count | Should -Be ($script:migrationCount - $Lost)
        }
    }

    function ThenTable
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [switch] $Not,

            [Parameter(Mandatory)]
            [switch] $Exists
        )

        Assert-Table -Name $Named -Not:$Not -Exists -DatabaseName $script:dbName
    }

    function WhenPopping
    {
        [CmdletBinding(DefaultParameterSetName='LastMigration')]
        param(
            [Parameter(Mandatory, ParameterSetName='ByCount')]
            [UInt32] $Count,

            [Parameter(Mandatory, ParameterSetName='ByName')]
            [String] $Named,

            [Parameter(Mandatory, ParameterSetName='ByID')]
            [String] $WithID,

            [Parameter(Mandatory, ParameterSetName='All')]
            [switch] $All,

            [Parameter(ParameterSetName='All')]
            [switch] $Force
        )

        $commonArgs = @{
            ConfigFilePath = $script:rivetJsonPath
        }

        if ($PSCmdlet.ParameterSetName -eq 'ByCount')
        {
            Invoke-Rivet -Pop -Count $Count @commonArgs
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Invoke-Rivet -Pop -Name $Named @commonArgs
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByID')
        {
            Invoke-Rivet -Pop -Name $WithID @commonArgs
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'All')
        {
            Invoke-Rivet -Pop -All -Force:$Force @commonArgs
        }
        else
        {
            Invoke-Rivet -Pop @commonArgs
        }
    }
}

Describe 'Pop-Migration' {
    BeforeAll {
        Remove-RivetTestDatabase -Name $script:dbName
    }

    BeforeEach {
        $script:testDirPath = Join-Path -Path $TestDrive -ChildPath ($script:testNum++)
        New-Item -Path $script:testDirPath -ItemType Directory
        $script:migrations = @()
        $script:rivetJsonPath = GivenRivetJsonFile -In $script:testDirPath -Database $script:dbName -PassThru
        $script:result = $null
        $Global:Error.Clear()

        $script:migration1 = GivenMigration 'Migration1' @'
            function Push-Migration
            {
                Add-Table 'Migration1' { int ID -Identity }
            }
            function Pop-Migration
            {
                Remove-Table 'Migration1'
            }
'@

        $script:migration2 = GivenMigration 'Migration2' @'
            function Push-Migration
            {
                Add-Table 'Migration2' { int ID -Identity }
            }
            function Pop-Migration
            {
                Remove-Table 'Migration2'
            }
'@

        $script:migration3 = GivenMigration 'Migration3' @'
            function Push-Migration
            {
                Add-Table 'Migration3' { int ID -Identity }
            }
            function Pop-Migration
            {
                Remove-Table 'Migration3'
            }
'@

        $script:migration4 = GivenMigration 'Migration4' @'
            function Push-Migration
            {
                Add-Table 'Migration4' { int ID -Identity }
            }
            function Pop-Migration
            {
                Remove-Table 'Migration4'
            }
'@

        Invoke-Rivet -Push -ConfigFilePath $script:rivetJsonPath

        $dbMigrationsDirPath =
            Join-Path -Path $script:testDirPath -ChildPath "Databases\${script:dbName}" -Resolve
        $expectedCount = Measure-MigrationScript -In $dbMigrationsDirPath
        ThenMigrationsTable -HasCount $expectedCount

        $script:migrationCount = Measure-Migration -InDatabase $script:dbName
    }

    AfterEach {
        Invoke-Rivet -Pop -All -Force -ConfigFilePath $script:rivetJsonPath
    }

    It 'should pop all migrations' {
        ThenMigrationsTable -IsNotEmpty
        ThenTable 'Migration1' -Exists
        ThenTable 'Migration2' -Exists
        ThenTable 'Migration3' -Exists
        ThenTable 'Migration4' -Exists
        WhenPopping -Count $script:migrationCount
        ThenMigrationsTable -Lost $script:migrationCount
        ThenTable 'Migration1' -Not -Exists
        ThenTable 'Migration2' -Not -Exists
        ThenTable 'Migration3' -Not -Exists
        ThenTable 'Migration4' -Not -Exists
    }

    It 'should write to activity table on pop' {
        ThenMigrationsTable -IsNotEmpty
        WhenPopping
        ThenMigrationsTable -Lost 1

        $rows = Get-ActivityInfo -DatabaseName $script:dbName

        $rows[-1].Operation | Should -Be 'Pop'
        $rows[-1].Name | Should -Be 'Migration4'
    }

    It 'should pop specific number of database migrations' {
        ThenMigrationsTable -IsNotEmpty
        WhenPopping -Count 2
        ThenMigrationsTable -Lost 2
    }

    It 'should pop one migration by default' {
        WhenPopping
        ThenMigrationsTable -Lost 1
        ThenTable 'Migration4' -Not -Exists
        ThenTable 'Migration3' -Exists
        ThenTable 'Migration2' -Exists
        ThenTable 'Migration1' -Exist
    }

    It 'should not re pop migrations' {
        WhenPopping
        ThenError -IsEmpty
        ThenMigrationsTable -Lost 1

        WhenPopping -Count 2
        ThenError -IsEmpty
        ThenMigrationsTable -Lost 3

        WhenPopping -Count 2
        ThenError -IsEmpty
        ThenMigrationsTable -Lost $script:migrationCount
    }

    It 'should support popping more than available migrations' {
        WhenPopping -Count ($script:migrationCount * 2)
        ThenError -IsEmpty
        ThenMigrationsTable -IsEmpty
    }


    It 'should stop popping migrations if one gives an error' {
        $m = GivenMigration 'PopFails' @'
            function Push-Migration
            {
                Add-Table 'Migration5' {
                    int 'ID' -Identity
                }
            }

            function Pop-Migration
            {
                Remove-Table 'DoNotExist'
            }
'@

        try
        {
            Invoke-Rivet -Push -ConfigFilePath $script:rivetJsonPath
            ThenError -IsEmpty

            { WhenPopping -All } | Should -Throw '*cannot drop the table ''dbo.DoNotExist''*'

            $Global:Error.Count | Should -BeGreaterThan 0

            ThenTable 'Migration5' -Exists
            ThenTable 'Migration4' -Exists
            ThenTable 'Migration3' -Exists
            ThenTable 'Migration2' -Exists
            ThenTable 'Migration1' -Exists
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
'@ | Set-Content -Path $m.FullName
        }
    }

    It 'should pop by name' {
        WhenPopping -Named 'Migration1'

        ThenTable 'Migration4' -Exists
        ThenTable 'Migration3' -Exists
        ThenTable 'Migration2' -Exists
        ThenTable 'Migration1' -Not -Exists
    }

    It 'should pop by name with wildcard' {
        WhenPopping -Named 'Migration*'

        ThenTable 'Migration4' -Not -Exists
        ThenTable 'Migration3' -Not -Exists
        ThenTable 'Migration2' -Not -Exists
        ThenTable 'Migration1' -Not -Exists
    }


    It 'should pop by name with no match' {
        { WhenPopping -Named 'Blah' } | Should -Throw '*Blah*does not exist*'

        ThenTable 'Migration4' -Exists
        ThenTable 'Migration3' -Exists
        ThenTable 'Migration2' -Exists
        ThenTable 'Migration1' -Exists
    }

    It 'should pop by ID' {
        $id = $script:migration1.BaseName.Substring(0,14)
        WhenPopping -WithID $id
        ThenTable 'Migration4' -Exists
        ThenTable 'Migration3' -Exists
        ThenTable 'Migration2' -Exists
        ThenTable 'Migration1' -Not -Exists
    }

    It 'should pop by ID with wildcard' {
        WhenPopping -WithID '20150101*'
        ThenMigrationsTable -IsEmpty
        ThenTable 'Migration4' -Not -Exists
        ThenTable 'Migration3' -Not -Exists
        ThenTable 'Migration2' -Not -Exists
        ThenTable 'Migration1' -Not -Exists
    }

    It 'should pop all' {
        WhenPopping -All
        ThenTable 'Migration4' -Not -Exists
        ThenTable 'Migration3' -Not -Exists
        ThenTable 'Migration2' -Not -Exists
        ThenTable 'Migration1' -Not -Exists
    }

    It 'should confirm popping anothers migration' {
        Invoke-RivetTestQuery -Query 'update [rivet].[Migrations] set Who = ''LittleLionMan''' `
                              -DatabaseName $script:dbName

        WhenPopping -All -Force
        ThenTable 'Migration4' -Not -Exists
        ThenTable 'Migration3' -Not -Exists
        ThenTable 'Migration2' -Not -Exists
        ThenTable 'Migration1' -Not -Exists
    }

    It 'should confirm popping old migrations' {
        Invoke-RivetTestQuery -Query 'update [rivet].[Migrations] set AtUtc = dateadd(minute, -21, AtUtc)' `
                              -DatabaseName $script:dbName

        WhenPopping -All -Force
        ThenTable 'Migration4' -Not -Exists
        ThenTable 'Migration3' -Not -Exists
        ThenTable 'Migration2' -Not -Exists
        ThenTable 'Migration1' -Not -Exists
    }
}
