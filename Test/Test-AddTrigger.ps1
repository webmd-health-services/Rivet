
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldAddTrigger
{
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

'@ | New-Migration -Name 'AddTrigger'

    Invoke-RTRivet -Push 'AddTrigger'

    Assert-Table 'Person'
    Assert-True (Test-DatabaseObject -SQLTrigger -Name "TestTrigger")
}

function Test-ShouldAddTriggerInCustomSchema
{
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

'@ | New-Migration -Name 'AddTrigger'

    Invoke-RTRivet -Push 'AddTrigger'

    Assert-Table 'Person' -SchemaName 'Test-AddTrigger'
    Assert-True (Test-DatabaseObject -SQLTrigger -Name "TestTrigger" -SchemaName 'Test-AddTrigger')
}

function Test-ShouldEscapeTriggerName
{
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

'@ | New-Migration -Name 'AddTrigger'

    Invoke-RTRivet -Push 'AddTrigger'

    Assert-Table 'AddTriggerTest' -SchemaName 'Add-Trigger'
    Assert-True (Test-DatabaseObject -SQLTrigger -Name "Test-Trigger" -SchemaName 'Add-Trigger')
    
}
