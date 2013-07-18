
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RemoveColumn' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRemoveColumns
{
    Invoke-Rivet -Push 'AddColumnNoDefaultsAllNull'
    
    Assert-True (Test-Table -Name 'AddColumnNoDefaultsAllNull')

    $commonArgs = @{ TableName = 'AddColumnNoDefaultsAllNull' }
    Assert-True (Test-Column -Name 'varchar' @commonArgs)
    Assert-True (Test-Column -Name 'varcharmax' @commonArgs)
    Assert-True (Test-Column -Name 'char' @commonArgs)
    Assert-True (Test-Column -Name 'nvarchar' @commonArgs)
    Assert-True (Test-Column -Name 'nvarcharmax' @commonArgs)
    Assert-True (Test-Column -Name 'nchar' @commonArgs)
    Assert-True (Test-Column -Name 'binary' @commonArgs)
    Assert-True (Test-Column -Name 'varbinary' @commonArgs)
    Assert-True (Test-Column -Name 'varbinarymax' @commonArgs)
    Assert-True (Test-Column -Name 'bigint' @commonArgs)
    Assert-True (Test-Column -Name 'int' @commonArgs)
    Assert-True (Test-Column -Name 'smallint' @commonArgs)
    Assert-True (Test-Column -Name 'tinyint' @commonArgs)
    Assert-True (Test-Column -Name 'numeric' @commonArgs)
    Assert-True (Test-Column -Name 'numericwithscale' @commonArgs)
    Assert-True (Test-Column -Name 'decimal' @commonArgs)
    Assert-True (Test-Column -Name 'decimalwithscale' @commonArgs)
    Assert-True (Test-Column -Name 'bit' @commonArgs)
    Assert-True (Test-Column -Name 'money' @commonArgs)
    Assert-True (Test-Column -Name 'smallmoney' @commonArgs)
    Assert-True (Test-Column -Name 'float' @commonArgs)
    Assert-True (Test-Column -Name 'floatwithprecision' @commonArgs)
    Assert-True (Test-Column -Name 'real' @commonArgs)
    Assert-True (Test-Column -Name 'date' @commonArgs)
    Assert-True (Test-Column -Name 'datetime' @commonArgs)
    Assert-True (Test-Column -Name 'datetime2' @commonArgs)
    Assert-True (Test-Column -Name 'datetimeoffset' @commonArgs)
    Assert-True (Test-Column -Name 'smalldatetime' @commonArgs)
    Assert-True (Test-Column -Name 'time' @commonArgs)
    Assert-True (Test-Column -Name 'xml' @commonArgs)
    Assert-True (Test-Column -Name 'sql_variant' @commonArgs)
    Assert-True (Test-Column -Name 'uniqueidentifier' @commonArgs)
    Assert-True (Test-Column -Name 'hierarchyid' @commonArgs)
    Assert-True (Test-Column -Name 'timestamp' @commonArgs)

    Invoke-Rivet -Pop ([Int]::MaxValue)

    Assert-False (Test-Column -Name 'varchar' @commonArgs)
    Assert-False (Test-Column -Name 'varcharmax' @commonArgs)
    Assert-False (Test-Column -Name 'char' @commonArgs)
    Assert-False (Test-Column -Name 'nvarchar' @commonArgs)
    Assert-False (Test-Column -Name 'nvarcharmax' @commonArgs)
    Assert-False (Test-Column -Name 'nchar' @commonArgs)
    Assert-False (Test-Column -Name 'binary' @commonArgs)
    Assert-False (Test-Column -Name 'varbinary' @commonArgs)
    Assert-False (Test-Column -Name 'varbinarymax' @commonArgs)
    Assert-False (Test-Column -Name 'bigint' @commonArgs)
    Assert-False (Test-Column -Name 'int' @commonArgs)
    Assert-False (Test-Column -Name 'smallint' @commonArgs)
    Assert-False (Test-Column -Name 'tinyint' @commonArgs)
    Assert-False (Test-Column -Name 'numeric' @commonArgs)
    Assert-False (Test-Column -Name 'numericwithscale' @commonArgs)
    Assert-False (Test-Column -Name 'decimal' @commonArgs)
    Assert-False (Test-Column -Name 'decimalwithscale' @commonArgs)
    Assert-False (Test-Column -Name 'bit' @commonArgs)
    Assert-False (Test-Column -Name 'money' @commonArgs)
    Assert-False (Test-Column -Name 'smallmoney' @commonArgs)
    Assert-False (Test-Column -Name 'float' @commonArgs)
    Assert-False (Test-Column -Name 'floatwithprecision' @commonArgs)
    Assert-False (Test-Column -Name 'real' @commonArgs)
    Assert-False (Test-Column -Name 'date' @commonArgs)
    Assert-False (Test-Column -Name 'datetime' @commonArgs)
    Assert-False (Test-Column -Name 'datetime2' @commonArgs)
    Assert-False (Test-Column -Name 'datetimeoffset' @commonArgs)
    Assert-False (Test-Column -Name 'smalldatetime' @commonArgs)
    Assert-False (Test-Column -Name 'time' @commonArgs)
    Assert-False (Test-Column -Name 'xml' @commonArgs)
    Assert-False (Test-Column -Name 'sql_variant' @commonArgs)
    Assert-False (Test-Column -Name 'uniqueidentifier' @commonArgs)
    Assert-False (Test-Column -Name 'hierarchyid' @commonArgs)
    Assert-False (Test-Column -Name 'timestamp' @commonArgs)
}
