
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateTable
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddTable' -Description 'Testing Add-Table migration' -Column {
        VarChar 'varchar' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        BigInt 'id' -Identity
    } -Option 'data_compression = none'

    # Sql 2012 feature
    # Add-Table 'FileTable' -FileTable
}

function Pop-Migration()
{
    Remove-Table 'AddTable'
}
'@ | New-Migration -Name 'CreateTable'
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
    @'
function Push-Migration()
{
    Add-Schema 'rivettest'
    Add-Table 'AddTableInRivetTest' {
        Int 'id' -Identity -Description 'AddTableInRivetTest identity column'
    } -SchemaName 'rivettest' -Description 'Testing Add-Table migration for custom schema.' 

    # Sql 2012 feature
    # Add-Table 'FileTable' -FileTable
}

function Pop-Migration()
{
    Remove-Table 'AddTableInRivetTest' -SchemaName 'rivettest'
    Remove-Schema 'rivettest'
}
'@ | New-Migration -Name 'CreateTableInCustomSchema'

    Invoke-Rivet -Push 'CreateTableInCustomSchema'

    Assert-Table 'AddTableInRivetTest' -SchemaName 'rivettest' -Description 'Testing Add-Table migration for custom schema.'
    Assert-Column -Name 'id' 'int' -NotNull -Seed 1 -Increment 1 -Description 'AddTableInRivetTest identity column' -TableName 'AddTableInRivetTest' -SchemaName 'rivettest'
}

function Test-ShouldCreateWithCustomFileGroup
{
    @'
function Push-Migration()
{
    Add-Table 'CustomFileGroup' {
        Int 'id' -Identity
    } -FileGroup '"rivet"' 
}

function Pop-Migration()
{
    Remove-Table 'CustomFileGroup'
}
'@ | New-Migration -Name 'CreateTableWithCustomFileGroup'

    Invoke-Rivet -Push 'CreateTableWithCustomFileGroup' -ErrorAction SilentlyContinue
    Assert-Error 1 'Invalid filegroup'
    Assert-False (Test-Table -Name 'CustomFileGroup')
}

function Test-ShouldCreateWithCustomTextImageFileGroup
{
    @'
function Push-Migration()
{
    Add-Table 'CustomTextImageFileGroup' {
        Int 'id' -Identity
    } -TextImageFileGroup '"rivet"' 
}

function Pop-Migration()
{
    Remove-Table 'CustomTextImageFileGroup'
}
'@ | New-Migration -Name 'CreateTableWithCustomTextImageFileGroup'

    Invoke-Rivet -Push 'CreateTableWithCustomTextImageFileGroup' -ErrorAction SilentlyContinue
    Assert-Error 1 'Cannot use TEXTIMAGE_ON'
    Assert-False (Test-Table -Name 'CustomTextImageFileGroup')
}

function Test-ShouldCreateWithCustomFileStreamFileGroup
{
    @'
function Push-Migration()
{
    Add-Table 'CustomTextImageFileGroup' {
        Int 'id' -Identity
    } -FileStreamFileGroup '"rivet"' 
}

function Pop-Migration()
{
    Remove-Table 'CustomTextImageFileGroup'
}
'@ | New-Migration -Name 'CreateTableWithCustomFileStreamFileGroup'
    Invoke-Rivet -Push 'CreateTableWithCustomFileStreamFileGroup' -ErrorAction SilentlyContinue
    Assert-Error 1 'FILESTREAM_ON cannot be specified'
    Assert-False (Test-Table -Name 'CustomFileStreamFileGroup')
}

function Test-ShouldCreateTableWithOptions
{
    @'
function Push-Migration()
{
    Add-Table 'AddTableWithOption' -Description 'Testing Add-Table migration' -Column {
        VarChar 'varchar' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        BigInt 'id' -Identity
    } -Option 'data_compression = page'
}

function Pop-Migration()
{
    Remove-Table 'AddTableWithOption'
}
'@ | New-Migration -Name 'CreateTableWithOption'

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
    Remove-Schema 'Add-Table'
}

'@ | New-Migration -Name 'AddTrigger'

    Invoke-Rivet -Push 'AddTrigger'

    Assert-Table 'Add-Table-Test' -SchemaName 'Add-Table'
}