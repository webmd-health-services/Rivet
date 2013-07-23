function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddIndex' 
    Start-RivetTest

    # yes, on PowerShell 2 these tests need a breather.  Not sure why.
    if( $PSVersionTable.PsVersion -eq '2.0' )
    {
        Start-Sleep -Milliseconds 200
    }
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddIndexWithOneColumn
{
    Invoke-Rivet -Push 'AddIndex'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe'

}

function Test-ShouldAddIndexWithMultipleColumns
{
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
    Invoke-Rivet -Push 'AddClusteredIndex'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -TestClustered
}

function Test-ShouldCreateUniqueIndex
{
    Invoke-Rivet -Push 'CreateUniqueIndex'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -TestUnique
}


function Test-ShouldCreateIndexWithOptions
{
    Invoke-Rivet -Push 'CreateIndexWithOptions'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -TestUnique -TestOption
}


function Test-ShouldCreateIndexWithFilterPredicate
{
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
    $Error.Clear()
    Invoke-Rivet -Push 'CreateIndexOnCustomFileGroup' -ErrorAction SilentlyContinue
    Assert-True (0 -lt $Error.Count)
    Assert-Like $Error[1].Exception.Message '*Invalid filegroup*'

}


function Test-ShouldCreateIndexOnCustomFileStream
{
    $Error.Clear()
    Invoke-Rivet -Push 'CreateIndexOnCustomFileStream' -ErrorAction SilentlyContinue
    Assert-True (0 -lt $Error.Count)
    Assert-Like $Error[1].Exception.Message '*FILESTREAM_ON cannot be specified*'
}