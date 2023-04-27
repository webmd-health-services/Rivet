
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Remove-Synonym' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should remove synonym' {
        @'
    function Push-Migration
    {
        Add-Synonym -Name 'Buzz' -TargetObjectName 'Fizz'
    }

    function Pop-Migration
    {
        Remove-Synonym -Name 'Buzz'
    }
'@ | New-TestMigration -Name 'RemoveSynonym'

        Invoke-RTRivet -Push 'RemoveSynonym'
        Assert-Synonym -Name 'Buzz' -TargetObjectName '[dbo].[Fizz]'

        Invoke-RTRivet -Pop 1

        (Get-Synonym -Name 'Buzz') | Should -BeNullOrEmpty
    }
}
