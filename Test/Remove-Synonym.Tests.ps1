
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    Remove-Item -Path 'alias:GivenMigration'

    $script:testDirPath = $null
    $script:testNum = 0
    $script:rivetJsonPath = $null
    $script:dbName = 'Remove-Synonym'

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

Describe 'Remove-Synonym' {
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

    It 'should remove synonym' {
        GivenMigration 'RemoveSynonym' @'
    function Push-Migration
    {
        Add-Synonym -Name 'Buzz' -TargetObjectName 'Fizz'
    }

    function Pop-Migration
    {
        Remove-Synonym -Name 'Buzz'
    }
'@

        Invoke-Rivet -Push 'RemoveSynonym' -ConfigFilePath $script:rivetJsonPath
        Assert-Synonym -Name 'Buzz' -TargetObjectName '[dbo].[Fizz]' -DatabaseName $script:dbName

        Invoke-Rivet -Pop -ConfigFilePath $script:rivetJsonPath

        (Get-Synonym -Name 'Buzz' -DatabaseName $script:dbName) | Should -BeNullOrEmpty
    }
}
