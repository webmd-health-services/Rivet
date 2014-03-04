
function Setup
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'AddTable' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldCreateTable
{
    Invoke-Rivet -Push 'CreateTable'

    Assert-Table 'AddTable' -Description 'Testing Add-Table migration'
    Assert-Column -Name 'varchar' 'varchar' -NotNull -Description 'varchar(max) constraint DF_AddTable_varchar default default' -TableName 'AddTable'
    Assert-Column -Name 'id' 'bigint' -NotNull -Seed 1 -Increment 1 -TableName 'AddTable'

    # Sql 2012 feature
    # Assert-Table 'FileTable'
    # Assert-Column -TableName 'FileTable' -Name  'path_locator' 'hierarchyid'
}

function Test-ShouldCreateTableInCustomSchema
{
    Invoke-Rivet -Push 'CreateTableInCustomSchema'

    Assert-Table 'AddTableInRivetTest' -SchemaName 'rivettest' -Description 'Testing Add-Table migration for custom schema.'
    Assert-Column -Name 'id' 'int' -NotNull -Seed 1 -Increment 1 -Description 'AddTableInRivetTest identity column' -TableName 'AddTableInRivetTest' -SchemaName 'rivettest'
}

function Test-ShouldCreateWithCustomFileGroup
{
    Invoke-Rivet -Push 'CreateTableWithCustomFileGroup' -ErrorAction SilentlyContinue
    Assert-Error 1 'Invalid filegroup'
    Assert-False (Test-Table -Name 'CustomFileGroup')
}

function Test-ShouldCreateWithCustomTextImageFileGroup
{
    Invoke-Rivet -Push 'CreateTableWithCustomTextImageFileGroup' -ErrorAction SilentlyContinue
    Assert-Error 1 'Cannot use TEXTIMAGE_ON'
    Assert-False (Test-Table -Name 'CustomTextImageFileGroup')
}

function Test-ShouldCreateWithCustomFileStreamFileGroup
{
    Invoke-Rivet -Push 'CreateTableWithCustomFileStreamFileGroup' -ErrorAction SilentlyContinue
    Assert-Error 1 'FILESTREAM_ON cannot be specified'
    Assert-False (Test-Table -Name 'CustomFileStreamFileGroup')
}

function Test-ShouldCreateTableWithOptions
{
    Invoke-Rivet -Push 'CreateTableWithOption' -ErrorAction SilentlyContinue
    
    if( $Global:Error )
    {
        $bingo = $Global:Error | Where-Object { $_ -like '*Cannot enable compression for object ''AddTableWithOption''*' }
        Assert-NotNull $bingo 'Unable to find error that indicates options were added to create table sql'
    }
    else
    {
        Assert-Table 'AddTableWithOption' -Description 'Testing Add-Table migration' -DataCompression 2
    }
}

function Test-ShouldEscapeNames
{
    @'
function Push-Migration
{
    Add-Schema 'Add-Table'
    Add-Table 'Add-Table-Test' -SchemaName 'Add-Table'  {
        Int ID -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'Add-Table-Test' -SchemaName 'Add-Table'
}

'@ | New-Migration -Name 'AddTrigger'

    Invoke-Rivet -Push 'AddTrigger'

    Assert-Table 'Add-Table-Test' -SchemaName 'Add-Table'
}