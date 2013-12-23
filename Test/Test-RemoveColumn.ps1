
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
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
}

function Pop-Migration()
{
    $tableParam = @{ TableName = 'AddColumnNoDefaultsAllNull' }
    Update-Table -SchemaName 'My-Schema' 'AddColumnNoDefaultsAllNull' -Remove 'varchar','varcharmax'
}
'@ | New-Migration -Name 'AddColumnNoDefaultsAllNull'

    Invoke-Rivet -Push 'AddColumnNoDefaultsAllNull'
    
    Assert-True (Test-Table -SchemaName 'My-Schema' -Name 'AddColumnNoDefaultsAllNull')

    $commonArgs = @{ TableName = 'AddColumnNoDefaultsAllNull' ; SchemaName = 'My-Schema' }
    Assert-True (Test-Column -Name 'varchar' @commonArgs)
    Assert-True (Test-Column -Name 'varcharmax' @commonArgs)

    Invoke-Rivet -Pop ([Int]::MaxValue)

    Assert-False (Test-Column -Name 'varchar' @commonArgs)
    Assert-False (Test-Column -Name 'varcharmax' @commonArgs)
}
