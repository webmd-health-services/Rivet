
function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 
    Start-RivetTest
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
}
'@ | New-Migration -Name 'AddIndex'

    Invoke-Rivet -Push 'AddIndex'

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
}
'@ | New-Migration -Name 'AddIndexMultipleColumns'

    Invoke-Rivet -Push 'AddIndexMultipleColumns'

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
}
'@ | New-Migration -Name 'AddClusteredIndex'

    Invoke-Rivet -Push 'AddClusteredIndex'

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
}
'@ | New-Migration -Name 'CreateUniqueIndex'

    Invoke-Rivet -Push 'CreateUniqueIndex'

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
}
'@ | New-Migration -Name 'CreateIndexWithOptions'

    Invoke-Rivet -Push 'CreateIndexWithOptions'

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
}
'@ | New-Migration -Name 'CreateIndexWithFilterPredicate'

    Invoke-Rivet -Push 'CreateIndexWithFilterPredicate'

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
}
'@ | New-Migration -Name 'CreateIndexOnCustomFileGroup'

    Invoke-Rivet -Push 'CreateIndexOnCustomFileGroup' -ErrorAction SilentlyContinue
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
}
'@ | New-Migration -Name 'CreateIndexOnCustomFileStream'

    Invoke-Rivet -Push 'CreateIndexOnCustomFileStream' -ErrorAction SilentlyContinue
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


}


'@ | New-Migration -Name 'CreateIndexWithDescending'

    Invoke-Rivet -Push 'CreateIndexWithDescending'

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
}
'@ | New-Migration -Name 'CreateIndexWithMultipleDescending'

    Invoke-Rivet -Push 'CreateIndexWithMultipleDescending'

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
}
'@ | New-Migration -Name 'AddIndex'

    Invoke-Rivet -Push 'AddIndex'

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
}
'@ | New-Migration -Name 'AddIndexWithOptionalName'

    Invoke-Rivet -Push 'AddIndexWithOptionalName'
    Assert-Index -Name 'Example' -ColumnName 'IndexMe'
}