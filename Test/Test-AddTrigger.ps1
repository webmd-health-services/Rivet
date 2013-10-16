function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddTrigger' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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
    
}

'@ | New-Migration -Name 'AddTrigger'

    Invoke-Rivet -Push 'AddTrigger'

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
    
}

'@ | New-Migration -Name 'AddTrigger'

    Invoke-Rivet -Push 'AddTrigger'

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
    Remove-Trigger -Name 'Test-Trigger' -SchemaName 'Add-Trigger'
    Remove-Table 'AddTriggerTest'
    Remove-Schema 'Add-Trigger'
}

'@ | New-Migration -Name 'AddTrigger'

    Invoke-Rivet -Push 'AddTrigger'

    Assert-Table 'AddTriggerTest' -SchemaName 'Add-Trigger'
    Assert-True (Test-DatabaseObject -SQLTrigger -Name "Test-Trigger" -SchemaName 'Add-Trigger')
    
}