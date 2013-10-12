
function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddIndexWithOneColumn
{
    @'
function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe'

}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddIndex'

    Invoke-Rivet -Push 'AddIndex'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe'

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
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -TestClustered
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
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -TestUnique
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
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -TestUnique -TestOption
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
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -TestFilter
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

    $Error.Clear()
    Invoke-Rivet -Push 'CreateIndexOnCustomFileGroup' -ErrorAction SilentlyContinue
    Assert-True (0 -lt $Error.Count)
    Assert-Like $Error[1].Exception.Message '*Invalid filegroup*'

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

    $Error.Clear()
    Invoke-Rivet -Push 'CreateIndexOnCustomFileStream' -ErrorAction SilentlyContinue
    Assert-True (0 -lt $Error.Count)
    Assert-Like $Error[1].Exception.Message '*FILESTREAM_ON cannot be specified*'
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
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -TestDescending @($true)

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
    Assert-Index -TableName 'AddIndex' -ColumnName "IndexMe","Ascending","IndexMe2" -TestDescending @($true, $false, $true)

}