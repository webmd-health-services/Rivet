
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
    Assert-Column -Name 'varchar' 'varchar' -Size 20 -Description 'varchar(20) not null' @commonArgs
    Assert-Column -Name 'varcharmax' 'varchar' -Max -Description 'varchar(max) not null' @commonArgs
    Assert-Column -Name 'char' 'char' -Size 10 -Description 'char(10) not null' @commonArgs
    Assert-Column -Name 'nvarchar' 'nvarchar' -Size 30 -Description 'nvarchar(30) not null' @commonArgs
    Assert-Column -Name 'nvarcharmax' 'nvarchar' -Max -Description 'nvarchar(max) not null' @commonArgs
    Assert-Column -Name 'nchar' 'nchar' -Size 35 -Description 'nchar(35) not null' @commonArgs
    Assert-Column -Name 'binary' 'binary' -Size 40 -Description 'binary(40) not null' @commonArgs
    Assert-Column -Name 'varbinary' 'varbinary' -Size 45 -Description 'varbinary(45) not null' @commonArgs
    Assert-Column -Name 'varbinarymax' 'varbinary' -Max -Description 'varbinary(max) not null' @commonArgs
    Assert-Column -Name 'bigint' 'bigint' -Description 'bigint not null' @commonArgs
    Assert-Column -Name 'int' 'int' -Description 'int not null' @commonArgs
    Assert-Column -Name 'smallint' 'smallint' -Description 'smallint not null' @commonArgs
    Assert-Column -Name 'tinyint' 'tinyint' -Description 'tinyint not null' @commonArgs
    Assert-Column -Name 'numeric' 'numeric' -Precision 1 -Description 'numeric(1) not null' @commonArgs
    Assert-Column -Name 'numericwithscale' 'numeric' -Precision 2 -Scale 2 -Description 'numeric(2,2) not null' @commonArgs
    Assert-Column -Name 'decimal' 'decimal' -Precision 4 -Description 'decimal(4) not null' @commonArgs
    Assert-Column -Name 'decimalwithscale' 'decimal' -Precision 5 -Scale 5 -Description 'decimal(5,5) not null' @commonArgs
    Assert-Column -Name 'bit' 'bit' -Description 'bit not null' @commonArgs
    Assert-Column -Name 'money' 'money' -Description 'money not null' @commonArgs
    Assert-Column -Name 'smallmoney' 'smallmoney' -Description 'smallmoney not null' @commonArgs
    Assert-Column -Name 'float' 'float' -Description 'float not null' @commonArgs
    Assert-Column -Name 'floatwithprecision' 'float' -Precision 53 -Description 'float(53) not null' @commonArgs
    Assert-Column -Name 'real' 'real' -Description 'real not null' @commonArgs
    Assert-Column -Name 'date' 'date' -Description 'date not null' @commonArgs
    Assert-Column -Name 'datetime' 'datetime' -Description 'datetime not null' @commonArgs
    Assert-Column -Name 'datetime2' 'datetime2' -Description 'datetime2 not null' @commonArgs
    Assert-Column -Name 'datetimeoffset' 'datetimeoffset' -Description 'datetimeoffset not null' @commonArgs
    Assert-Column -Name 'smalldatetime' 'smalldatetime' -Description 'smalldatetime not null' @commonArgs
    Assert-Column -Name 'time' 'time' -Description 'time not null' @commonArgs
    Assert-Column -Name 'xml' 'xml' -Description 'xml not null' @commonArgs
    Assert-Column -Name 'sql_variant' 'sql_variant' -Description 'sql_variant not null' @commonArgs
    Assert-Column -Name 'uniqueidentifier' 'uniqueidentifier' -Description 'uniqueidentifier not null' @commonArgs
    Assert-Column -Name 'hierarchyid' 'hierarchyid' -Description 'hierarchyid not null' @commonArgs

    $commonArgs.Nullable = $false
    Assert-Column -Name 'timestamp' 'timestamp' -Description 'timestamp' @commonArgs
}

function Test-ShouldAddNotNullableColumnsWithDefaults
{
    Invoke-Pstep -Push

    Assert-True (Test-Table -Name 'AddColumnDefaultsNotNull')

    $commonArgs = @{ TableName = 'AddColumnDefaultsNotNull'; Nullable = $false; }
    Assert-Column -Name 'varchar' 'varchar' -Size 20 -Default "'varchar'" -Description 'varchar(20) not null' @commonArgs
    Assert-Column -Name 'varcharmax' 'varchar' -Max -Default "'varcharmax'" -Description 'varchar(max) not null' @commonArgs
    Assert-Column -Name 'char' 'char' -Size 10 -Default "'char'" -Description 'char(10) not null' @commonArgs
    Assert-Column -Name 'nvarchar' 'nvarchar' -Size 30 -Default "'nvarchar'" -Description 'nvarchar(30) not null' @commonArgs
    Assert-Column -Name 'nvarcharmax' 'nvarchar' -Max -Default "'nvarcharmax'" -Description 'nvarchar(max) not null' @commonArgs
    Assert-Column -Name 'nchar' 'nchar' -Size 35 -Default "'nchar'" -Description 'nchar(35) not null' @commonArgs
    Assert-Column -Name 'binary' 'binary' -Size 40 -Default 1 -Description 'binary(40) not null' @commonArgs
    Assert-Column -Name 'varbinary' 'varbinary' -Size 45 -Default 2 -Description 'varbinary(45) not null' @commonArgs
    Assert-Column -Name 'varbinarymax' 'varbinary' -Max -Default 3 -Description 'varbinary(max) not null' @commonArgs
    Assert-Column -Name 'bigint' 'bigint' -Default ([int64]::MaxValue) -Description 'bigint not null' @commonArgs
    Assert-Column -Name 'int' 'int' -Default ([int]::MaxValue) -Description 'int not null' @commonArgs
    Assert-Column -Name 'smallint' 'smallint' -Default ([int16]::MaxValue) -Description 'smallint not null' @commonArgs
    Assert-Column -Name 'tinyint' 'tinyint' -Default ([byte]::MaxValue) -Description 'tinyint not null' @commonArgs
    Assert-Column -Name 'numeric' 'numeric' -Precision 1 -Default '1.11' -Description 'numeric(1) not null' @commonArgs
    Assert-Column -Name 'numericwithscale' 'numeric' -Precision 2 -Scale 2 -Default '2.22' -Description 'numeric(2,2) not null' @commonArgs
    Assert-Column -Name 'decimal' 'decimal' -Precision 4 -Default '3.33' -Description 'decimal(4) not null' @commonArgs
    Assert-Column -Name 'decimalwithscale' 'decimal' -Precision 5 -Scale 5 -Default '4.44' -Description 'decimal(5,5) not null' @commonArgs
    Assert-Column -Name 'bit' 'bit' -Default '1' -Description 'bit not null' @commonArgs
    Assert-Column -Name 'money' 'money' -Default '6.66' -Description 'money not null' @commonArgs
    Assert-Column -Name 'smallmoney' 'smallmoney' -Default '7.77' -Description 'smallmoney not null' @commonArgs
    Assert-Column -Name 'float' 'float' -Default '8.88' -Description 'float not null' @commonArgs
    Assert-Column -Name 'floatwithprecision' 'float' -Precision 53 -Default '9.99' -Description 'float(53) not null' @commonArgs
    Assert-Column -Name 'real' 'real' -Default '10.10' -Description 'real not null' @commonArgs
    Assert-Column -Name 'date' 'date' -Default 'getdate()' -Description 'date not null' @commonArgs
    Assert-Column -Name 'datetime' 'datetime' -Default 'getdate()' -Description 'datetime not null' @commonArgs
    Assert-Column -Name 'datetime2' 'datetime2' -Default 'getdate()' -Description 'datetime2 not null' @commonArgs
    Assert-Column -Name 'datetimeoffset' 'datetimeoffset' -Default 'getdate()' -Description 'datetimeoffset not null' @commonArgs
    Assert-Column -Name 'smalldatetime' 'smalldatetime' -Default 'getdate()' -Description 'smalldatetime not null' @commonArgs
    Assert-Column -Name 'time' 'time' -Default 'getdate()' -Description 'time not null' @commonArgs
    Assert-Column -Name 'xml' 'xml' -Default "'<empty />'" -Description 'xml not null' @commonArgs
    Assert-Column -Name 'sql_variant' 'sql_variant' -Default "'sql_variant'" -Description 'sql_variant not null' @commonArgs
    Assert-Column -Name 'uniqueidentifier' 'uniqueidentifier' -Default 'newid()' -Description 'uniqueidentifier not null' @commonArgs
    Assert-Column -Name 'hierarchyid' 'hierarchyid' -Default '0x11' -Description 'hierarchyid not null' @commonArgs
}
