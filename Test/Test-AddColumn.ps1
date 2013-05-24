

function Setup
{
    Import-Module -Name (Join-Path $TestDir 'PstepTest') -ArgumentList 'AddColumn' 
    Start-PstepTest
}

function TearDown
{
    Stop-PstepTest
    Remove-Module PstepTest
}

function Test-ShouldAddColumns
{
    Invoke-Pstep -Push

    Assert-True (Test-Table -Name 'AddColumnNoDefaultsAllNull')

    $commonArgs = @{ TableName = 'AddColumnNoDefaultsAllNull'; Nullable = $true; }
    Assert-Column -Name 'varchar' 'varchar' -Size 20 @commonArgs
    Assert-Column -Name 'varcharmax' 'varchar' -Max @commonArgs
    Assert-Column -Name 'char' 'char' -Size 10 @commonArgs
    Assert-Column -Name 'nvarchar' 'nvarchar' -Size 30 @commonArgs
    Assert-Column -Name 'nvarcharmax' 'nvarchar' -Max @commonArgs
    Assert-Column -Name 'nchar' 'nchar' -Size 35 @commonArgs
    Assert-Column -Name 'binary' 'binary' -Size 40 @commonArgs
    Assert-Column -Name 'varbinary' 'varbinary' -Size 45 @commonArgs
    Assert-Column -Name 'varbinarymax' 'varbinary' -Max @commonArgs
    Assert-Column -Name 'bigint' 'bigint' @commonArgs
    Assert-Column -Name 'int' 'int' @commonArgs
    Assert-Column -Name 'smallint' 'smallint' @commonArgs
    Assert-Column -Name 'tinyint' 'tinyint' @commonArgs
    Assert-Column -Name 'numeric' 'numeric' -Precision 1 @commonArgs
    Assert-Column -Name 'numericwithscale' 'numeric' -Precision 2 -Scale 2 @commonArgs
    Assert-Column -Name 'decimal' 'decimal' -Precision 4 @commonArgs
    Assert-Column -Name 'decimalwithscale' 'decimal' -Precision 5 -Scale 5 @commonArgs
    Assert-Column -Name 'bit' 'bit' @commonArgs
    Assert-Column -Name 'money' 'money' @commonArgs
    Assert-Column -Name 'smallmoney' 'smallmoney' @commonArgs
    Assert-Column -Name 'float' 'float' @commonArgs
    Assert-Column -Name 'floatwithprecision' 'float' -Precision 53 @commonArgs
    Assert-Column -Name 'real' 'real' @commonArgs
    Assert-Column -Name 'date' 'date' @commonArgs
    Assert-Column -Name 'datetime' 'datetime' @commonArgs
    Assert-Column -Name 'datetime2' 'datetime2' @commonArgs
    Assert-Column -Name 'datetimeoffset' 'datetimeoffset' @commonArgs
    Assert-Column -Name 'smalldatetime' 'smalldatetime' @commonArgs
    Assert-Column -Name 'time' 'time' @commonArgs
    Assert-Column -Name 'xml' 'xml' @commonArgs
    Assert-Column -Name 'sql_variant' 'sql_variant' @commonArgs
    Assert-Column -Name 'uniqueidentifier' 'uniqueidentifier' @commonArgs
    Assert-Column -Name 'hierarchyid' 'hierarchyid' @commonArgs

    $commonArgs.Nullable = $false
    Assert-Column -Name 'timestamp' 'timestamp' @commonArgs
}