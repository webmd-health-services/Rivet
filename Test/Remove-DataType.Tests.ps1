
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    Remove-Item -Path 'alias:GivenMigration'

    $script:testDirPath = $null
    $script:testNum = 0
    $script:rivetJsonPath = $null
    $script:dbName = 'Remove-DataType'

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
}

Describe 'Remove-DataType' {
    BeforeEach {
        $script:testDirPath = Join-Path -Path $TestDrive -ChildPath ($script:testNum++)
        New-Item -Path $script:testDirPath -ItemType Directory
        $script:migrations = @()
        $script:rivetJsonPath = GivenRivetJsonFile -In $script:testDirPath -Database $script:dbName -PassThru
        $Global:Error.Clear()
    }

    AfterEach {
        Invoke-Rivet -Pop -All -Force -ConfigFilePath $script:rivetJsonPath
    }

    It 'should remove data type by table' {
        # Yes.  Spaces in names so we check that the names get quoted.
        GivenMigration 'ByTable' @'
            function Push-Migration
            {
                Add-DataType 'Users DT' -AsTable { varchar 'Name' 50 } -TableConstraint 'primary key'
            }

            function Pop-Migration
            {
                Remove-DataType 'Users DT'
            }
'@

        Invoke-Rivet -Push -ConfigFilePath $script:rivetJsonPath

        $temp = Invoke-RivetTestQuery -Query 'select * from sys.table_types' -DatabaseName $script:dbName
        $temp | Should -Not -BeNullOrEmpty
        'Users DT' | Should -Be $temp.name

        Invoke-Rivet -Pop -ConfigFilePath $script:rivetJsonPath
        $temp = Invoke-RivetTestQuery -Query 'select * from sys.table_types' -DatabaseName $script:dbName
        $temp | Should -BeNullOrEmpty
    }
}
