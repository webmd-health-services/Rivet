
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Setup
{
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldRemoveColumns
{
    @'
function Push-Migration()
{
    Add-Schema 'My-Schema'

    Add-Table -SchemaName 'My-Schema' AddColumnNoDefaultsAllNull {
        Int 'id' -Identity 
        VarChar 'varchar' -Size 50
        VarChar 'varcharmax' -Max
    }

    $tableParam = @{ TableName = 'AddColumnNoDefaultsAllNull' }
    Update-Table -SchemaName 'My-Schema' 'AddColumnNoDefaultsAllNull' -Remove 'varchar','varcharmax'
}

function Pop-Migration()
{
    Remove-Table -SchemaName 'My-Schema' 'AddColumnNoDefaultsAllNull'
    Remove-Schema 'My-Schema'
}
'@ | New-Migration -Name 'AddColumnNoDefaultsAllNull'

    Invoke-RTRivet -Push 'AddColumnNoDefaultsAllNull'
    
    $commonArgs = @{ TableName = 'AddColumnNoDefaultsAllNull' ; SchemaName = 'My-Schema' }
    Assert-False (Test-Column -Name 'varchar' @commonArgs)
    Assert-False (Test-Column -Name 'varcharmax' @commonArgs)
}
