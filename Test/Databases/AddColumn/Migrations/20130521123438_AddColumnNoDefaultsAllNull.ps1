<#
Your migration is ready to go!  We've set you up with default migrations that just run raw SQL.  Here are some other migrations:

If you have a script for a scripted object, you can use these functions:

    Remove-StoredProcedure -Name <string> [-Schema <string>] [-IfExists]
    Remove-UserDefinedFunction -Name <string> [-Schema <string>] [-IfExists]
    Remove-View -Name <string> [-Schema <string>] [-IfExists]
    Set-StoredProcedure -Name <string> [-Schema <string>]
    Set-UserDefinedFunction -Name <string> [-Schema <string>]
    Set-View -Name <string> [-Schema <string>]
    
To execute raw SQL:

    Invoke-Query -Query <string>

You can use a PowerShell here string for longer queries and so you don't have to escape quotes:

    Invoke-Query -Query @'
       -- SQL goes here    
'@  # '@ must be the first two characters on the line to close the string.
 
To execute a raw SQL script *file*:

    Invoke-SqlScript -Path <string>

To get the path to a script, use the $DBScriptRoot variable, which is set to the current databases scripts root directory:

     = Join-Path  Miscellaneous\CreateMyCustomObject.sql
    Invoke-SqlScript -Path 
    
#>

function Push-Migration()
{

    Invoke-Query -Query @'
    create table AddColumnNoDefaultsAllNull (
        id int not null
    )
'@
    $commonArgs = @{
                        TableName = 'AddColumnNoDefaultsAllNull'
                   }

    Add-Column -Name varchar -Varchar -Size 20 -Description 'varchar(20) null' @commonArgs
    Add-Column -Name varcharmax -Varchar -Description 'varchar(max) null' @commonArgs
    Add-Column char -Char 10 -Description 'char(10) null' @commonArgs
    Add-Column nchar -Char 35 -Unicode -Description 'nchar(35) null' @commonArgs
    Add-Column nvarchar -VarChar 30 -Unicode -Description 'nvarchar(30) null' @commonArgs
    Add-Column nvarcharmax -VarChar -Unicode -Description 'nvarchar(max) null' @commonArgs
    Add-Column binary -Binary 40 -Description 'binary(40) null' @commonArgs
    Add-Column varbinary -VarBinary 45 -Description 'varbinary(45) null' @commonArgs
    Add-Column varbinarymax -VarBinary -Description 'varbinary(max) null' @commonArgs
    Add-Column bigint -BigInt -Description 'bigint null' @commonArgs
    Add-Column int -Int -Description 'int null' @commonArgs
    Add-Column smallint -SmallInt -Description 'smallint null' @commonArgs
    Add-Column tinyint -TinyInt -Description 'tinyint null' @commonArgs
    Add-Column numeric -Numeric 1 -Description 'numeric(1) null' @commonArgs
    Add-Column numericwithscale -Numeric 2 2 -Description 'numeric(2,2) null' @commonArgs
    Add-Column decimal -Decimal 4 -Description 'decimal(4) null' @commonArgs
    Add-Column decimalwithscale -Decimal 5 5 -Description 'decimal(5,5) null' @commonArgs
    Add-Column bit -Bit -Description 'bit null' @commonArgs
    Add-Column money -Money -Description 'money null' @commonArgs
    Add-Column smallmoney -SmallMoney -Description 'smallmoney null' @commonArgs
    Add-Column float -Float -Description 'float null' @commonArgs
    Add-Column floatwithprecision -Float 53 -Description 'float(53) null' @commonArgs
    Add-Column real -Real -Description 'real null' @commonArgs
    Add-Column date -Date -Description 'date null' @commonArgs
    Add-Column datetime -DateTime -Description 'datetime null' @commonArgs
    Add-Column datetime2 -Datetime2 -Description 'datetime2 null' @commonArgs
    Add-Column datetimeoffset -DateTimeOffset -Description 'datetimeoffset null' @commonArgs
    Add-Column smalldatetime -SmallDateTime -Description 'smalldatetime null' @commonArgs
    Add-Column time -Time -Description 'time null' @commonArgs
    Add-Column uniqueidentifier -UniqueIdentifier -Description 'uniqueidentifier null' @commonArgs
    Add-Column xml -Xml -Description 'xml null' @commonArgs
    Add-Column sql_variant -SqlVariant -Description 'sql_variant null' @commonArgs
    Add-Column hierarchyid -HierarchyID -Description 'hierarchyid null' @commonArgs
    Add-Column timestamp -RowVersion -Description 'timestamp' @commonArgs
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table AddColumnNoDefaultsAllNull
'@
}
