
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
    Assert-Column -Name 'varchar' 'varchar' -Size 20 -Description 'varchar(20) null' @commonArgs
    Assert-Column -Name 'varcharmax' 'varchar' -Max -Description 'varchar(max) null' @commonArgs
    Assert-Column -Name 'char' 'char' -Size 10 -Description 'char(10) null' @commonArgs
    Assert-Column -Name 'nvarchar' 'nvarchar' -Size 30 -Description 'nvarchar(30) null' @commonArgs
    Assert-Column -Name 'nvarcharmax' 'nvarchar' -Max -Description 'nvarchar(max) null' @commonArgs
    Assert-Column -Name 'nchar' 'nchar' -Size 35 -Description 'nchar(35) null' @commonArgs
    Assert-Column -Name 'binary' 'binary' -Size 40 -Description 'binary(40) null' @commonArgs
    Assert-Column -Name 'varbinary' 'varbinary' -Size 45 -Description 'varbinary(45) null' @commonArgs
    Assert-Column -Name 'varbinarymax' 'varbinary' -Max -Description 'varbinary(max) null' @commonArgs
    Assert-Column -Name 'bigint' 'bigint' -Description 'bigint null' @commonArgs
    Assert-Column -Name 'int' 'int' -Description 'int null' @commonArgs
    Assert-Column -Name 'smallint' 'smallint' -Description 'smallint null' @commonArgs
    Assert-Column -Name 'tinyint' 'tinyint' -Description 'tinyint null' @commonArgs
    Assert-Column -Name 'numeric' 'numeric' -Precision 1 -Description 'numeric(1) null' @commonArgs
    Assert-Column -Name 'numericwithscale' 'numeric' -Precision 2 -Scale 2 -Description 'numeric(2,2) null' @commonArgs
    Assert-Column -Name 'decimal' 'decimal' -Precision 4 -Description 'decimal(4) null' @commonArgs
    Assert-Column -Name 'decimalwithscale' 'decimal' -Precision 5 -Scale 5 -Description 'decimal(5,5) null' @commonArgs
    Assert-Column -Name 'bit' 'bit' -Description 'bit null' @commonArgs
    Assert-Column -Name 'money' 'money' -Description 'money null' @commonArgs
    Assert-Column -Name 'smallmoney' 'smallmoney' -Description 'smallmoney null' @commonArgs
    Assert-Column -Name 'float' 'float' -Description 'float null' @commonArgs
    Assert-Column -Name 'floatwithprecision' 'float' -Precision 53 -Description 'float(53) null' @commonArgs
    Assert-Column -Name 'real' 'real' -Description 'real null' @commonArgs
    Assert-Column -Name 'date' 'date' -Description 'date null' @commonArgs
    Assert-Column -Name 'datetime' 'datetime' -Description 'datetime null' @commonArgs
    Assert-Column -Name 'datetime2' 'datetime2' -Description 'datetime2 null' @commonArgs
    Assert-Column -Name 'datetimeoffset' 'datetimeoffset' -Description 'datetimeoffset null' @commonArgs
    Assert-Column -Name 'smalldatetime' 'smalldatetime' -Description 'smalldatetime null' @commonArgs
    Assert-Column -Name 'time' 'time' -Description 'time null' @commonArgs
    Assert-Column -Name 'xml' 'xml' -Description 'xml null' @commonArgs
    Assert-Column -Name 'sql_variant' 'sql_variant' -Description 'sql_variant null' @commonArgs
    Assert-Column -Name 'uniqueidentifier' 'uniqueidentifier' -Description 'uniqueidentifier null' @commonArgs
    Assert-Column -Name 'hierarchyid' 'hierarchyid' -Description 'hierarchyid null' @commonArgs

    $commonArgs.Nullable = $false
    Assert-Column -Name 'timestamp' 'timestamp' -Description 'timestamp' @commonArgs
}

