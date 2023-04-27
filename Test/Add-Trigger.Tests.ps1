
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-Trigger' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should add trigger' {
        @'
    function Push-Migration
    {
        Add-Table 'Person' {
            Int 'ID' -Identity
        }

        Add-Trigger 'TestTrigger' -Definition "on dbo.Person after insert, update as return"
    }

    function Pop-Migration
    {
        Remove-Table 'Person'
    }

'@ | New-TestMigration -Name 'AddTrigger'

        Invoke-RTRivet -Push 'AddTrigger'

        Assert-Table 'Person'
        (Test-DatabaseObject -SQLTrigger -Name "TestTrigger") | Should -BeTrue
    }

    It 'should add trigger in custom schema' {
        @'
    function Push-Migration
    {
        Add-Schema 'Test-AddTrigger'
        Add-Table -SchemaName 'Test-AddTrigger' 'Person' {
            Int 'ID' -Identity
        }

        Add-Trigger -SchemaName 'Test-AddTrigger' 'TestTrigger' -Definition "on [Test-AddTrigger].Person after insert, update as return"
    }

    function Pop-Migration
    {
        Remove-Table 'Person' -SchemaName 'Test-AddTrigger'
        Remove-Schema 'Test-AddTrigger'
    }

'@ | New-TestMigration -Name 'AddTrigger'

        Invoke-RTRivet -Push 'AddTrigger'

        Assert-Table 'Person' -SchemaName 'Test-AddTrigger'
        (Test-DatabaseObject -SQLTrigger -Name "TestTrigger" -SchemaName 'Test-AddTrigger') | Should -BeTrue
    }

    It 'should escape trigger name' {
        @'
    function Push-Migration
    {
        Add-Schema 'Add-Trigger'
        Add-Table 'AddTriggerTest' -SchemaName 'Add-Trigger' {
            Int ID -Identity
        }

        Add-Trigger -Name 'Test-Trigger' -SchemaName 'Add-Trigger' -Definition "on [Add-Trigger].AddTriggerTest after insert, update as return"
    }

    function Pop-Migration
    {
        Remove-Table 'AddTriggerTest' -SchemaName 'Add-Trigger'
        Remove-Schema 'Add-Trigger'
    }

'@ | New-TestMigration -Name 'AddTrigger'

        Invoke-RTRivet -Push 'AddTrigger'

        Assert-Table 'AddTriggerTest' -SchemaName 'Add-Trigger'
        (Test-DatabaseObject -SQLTrigger -Name "Test-Trigger" -SchemaName 'Add-Trigger') | Should -BeTrue

    }
}
