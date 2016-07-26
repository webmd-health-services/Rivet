
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
    & (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Import-Rivet.ps1' -Resolve)
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldAddIndexWithOneColumn
{
    # Yes.  Spaces in the name so we check the name gets quoted.
    @'
function Push-Migration()
{

    Add-Table -Name 'Add Index' {
        Int 'Index Me' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'Add Index' -ColumnName 'Index Me'

}

function Pop-Migration()
{
    Remove-Table 'Add Index'
}
'@ | New-TestMigration -Name 'AddIndex'

    Invoke-RTRivet -Push 'AddIndex'

    ##Assert Table and Column
    Assert-True (Test-Table 'Add Index')
    Assert-True (Test-Column -Name 'Index Me' -TableName 'Add Index')

    ##Assert Index
    Assert-Index -TableName 'Add Index' -ColumnName 'Index Me'

}

function Test-ShouldAddIndexWithMultipleColumns
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
        Char 'IndexMe2' -Size 255 -NotNull
        Int 'DonotIndex' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName "IndexMe","IndexMe2"
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'AddIndexMultipleColumns'

    Invoke-RTRivet -Push 'AddIndexMultipleColumns'

    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe2' -TableName 'AddIndex')
    Assert-True (Test-Column -Name 'DoNotIndex' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName "IndexMe","IndexMe2"

}

function Test-ShouldCreateClusteredIndex
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Clustered
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'AddClusteredIndex'

    Invoke-RTRivet -Push 'AddClusteredIndex'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Clustered
}

function Test-ShouldCreateUniqueIndex
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'CreateUniqueIndex'

    Invoke-RTRivet -Push 'CreateUniqueIndex'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique
}


function Test-ShouldCreateIndexWithOptions
{
    @'
function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF')

}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'CreateIndexWithOptions'

    Invoke-RTRivet -Push 'CreateIndexWithOptions'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique -IgnoreDupKey -DenyRowLocks
}


function Test-ShouldCreateIndexWithFilterPredicate
{
    @'
function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
        Int 'EndDate' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Where 'EndDate IS NOT NULL'

}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'CreateIndexWithFilterPredicate'

    Invoke-RTRivet -Push 'CreateIndexWithFilterPredicate'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')
    Assert-True (Test-Column -Name 'EndDate' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Filter '([EndDate] IS NOT NULL)'
}

function Test-ShouldCreateIndexOnCustomFileGroup
{
    @'
function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
        Int 'EndDate' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -On 'ThisShouldFail'

}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'CreateIndexOnCustomFileGroup'

    Invoke-RTRivet -Push 'CreateIndexOnCustomFileGroup' -ErrorAction SilentlyContinue
    Assert-Error 1 'Invalid filegroup'
}


function Test-ShouldCreateIndexOnCustomFileStream
{
    @'
function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
        Int 'EndDate' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -FileStreamOn 'ThisShouldFail'

}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'CreateIndexOnCustomFileStream'

    Invoke-RTRivet -Push 'CreateIndexOnCustomFileStream' -ErrorAction SilentlyContinue
    Assert-Error 1 'FILESTREAM_ON cannot be specified'
}

function Test-ShouldCreateIndexWithDescending
{
@'
function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Descending @($true)

}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}


'@ | New-TestMigration -Name 'CreateIndexWithDescending'

    Invoke-RTRivet -Push 'CreateIndexWithDescending'

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Descending @($true)

}

function Test-ShouldCreateIndexWithMultipleDescending
{
@'
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
        Int 'Ascending' -NotNull
        Int 'IndexMe2' -NotNull
    }

    Add-Index -TableName 'AddIndex' -ColumnName "IndexMe","Ascending","IndexMe2" -Descending @($true, $false, $true)
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'CreateIndexWithMultipleDescending'

    Invoke-RTRivet -Push 'CreateIndexWithMultipleDescending'

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName "IndexMe","Ascending","IndexMe2" -Descending @($true, $false, $true)
}

function Test-ShouldQuoteIndexName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Add-Index' {
        Int 'IndexMe' -NotNull
    }

    Add-Index -TableName 'Add-Index' -ColumnName 'IndexMe'
}

function Pop-Migration()
{
    Remove-Table 'Add-Index'
}
'@ | New-TestMigration -Name 'AddIndex'

    Invoke-RTRivet -Push 'AddIndex'

    Assert-Index -TableName 'Add-Index' -ColumnName 'IndexMe'
}

function Test-ShouldAddIndexWithOptionalName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Add-Index' {
        Int 'IndexMe' -NotNull
    }

    Add-Index -TableName 'Add-Index' -ColumnName 'IndexMe' -Name 'Example'
}

function Pop-Migration()
{
    Remove-Table 'Add-Index'
}
'@ | New-TestMigration -Name 'AddIndexWithOptionalName'

    Invoke-RTRivet -Push 'AddIndexWithOptionalName'
    Assert-Index -Name 'Example' -ColumnName 'IndexMe'
}

function Test-ShouldAddIndexWithIncludeColumn
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'Index Me' -NotNull
        Int 'Include Me' -NotNull
    }

    #Add an Index to 'Index Me' and include the column 'Include Me'
    Add-Index -TableName 'AddIndex' -ColumnName 'Index Me' -Include 'Include Me'
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'AddIndex'

    Invoke-RTRivet -Push 'AddIndex'

    Assert-Index -TableName 'AddIndex' -ColumnName 'Index Me' -Include 'Include Me'
}

function Test-ShouldAddIndexWithMultipleIncludeColumns
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'Index Me' -NotNull
        Int 'Include Me' -NotNull
        Int 'Include Me 2' -NotNull
    }

    #Add an Index to 'Index Me' and include the column 'Include Me'
    Add-Index -TableName 'AddIndex' -ColumnName 'Index Me' -Include "Include Me","Include Me 2"
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-TestMigration -Name 'AddIndex'

    Invoke-RTRivet -Push 'AddIndex'

    Assert-Index -TableName 'AddIndex' -ColumnName 'Index Me' -Include "Include Me","Include Me 2"
}

function Test-ShouldSetTimeout
{
    $op = Add-Index -TableName 'fubar' -SchemaName 'snafu' -ColumnName 'fubar','snafu' -Timeout 400
    Assert-Equal 400 $op.CommandTimeout
}

function Test-ShouldSetTimeoutToZero
{
    $op = Add-Index -TableName 'fubar' -ColumnName 'snafu' -Timeout 0
    Assert-Equal 0 $op.CommandTimeout
}
