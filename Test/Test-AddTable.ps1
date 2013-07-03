
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'PstepTest') -ArgumentList 'AddTable' 
    Start-PstepTest
}

function TearDown
{
    Stop-PstepTest
    Remove-Module PstepTest
}

function Test-ShouldCreateTable
{
    Invoke-Pstep -Push 'CreateTable'

    Assert-Table 'AddTable' -Description 'Testing Add-Table migration'
    Assert-Column -Name 'varchar' 'varchar' -NotNull -Description 'varchar(max) constraint DF_AddTable_varchar default default' -TableName 'AddTable'
    Assert-Column -Name 'id' 'bigint' -NotNull -Seed 1 -Increment 1 -TableName 'AddTable'

    # Sql 2012 feature
    # Assert-Table 'FileTable'
    # Assert-Column -TableName 'FileTable' -Name  'path_locator' 'hierarchyid'
}

function Test-ShouldCreateTableInCustomSchema
{
    Invoke-Pstep -Push 'CreateTableInCustomSchema'

    Assert-Table 'AddTableInPstepTest' -SchemaName 'psteptest' -Description 'Testing Add-Table migration for custom schema.'
    Assert-Column -Name 'id' 'int' -NotNull -Seed 1 -Increment 1 -Description 'AddTableInPstepTest identity column' -TableName 'AddTableInPstepTest' -SchemaName 'psteptest'
}

function Test-ShouldCreateWithCustomFileGroup
{
    $Error.Clear()
    Invoke-Pstep -Push 'CreateTableWithCustomFileGroup' -ErrorAction SilentlyContinue
    Assert-True (0 -lt $Error.Count)
    Assert-Like $Error[1].Exception.Message '*Invalid filegroup*'
    Assert-False (Test-Table -Name 'CustomFileGroup')
}

function Test-ShouldCreateWithCustomTextImageFileGroup
{
    $Error.Clear()
    Invoke-Pstep -Push 'CreateTableWithCustomTextImageFileGroup' -ErrorAction SilentlyContinue
    Assert-True (0 -lt $Error.Count)
    Assert-Like $Error[1].Exception.Message '*Cannot use TEXTIMAGE_ON*'
    Assert-False (Test-Table -Name 'CustomTextImageFileGroup')
}

function Test-ShouldCreateWithCustomFileStreamFileGroup
{
    $Error.Clear()
    Invoke-Pstep -Push 'CreateTableWithCustomFileStreamFileGroup' -ErrorAction SilentlyContinue
    Assert-True (0 -lt $Error.Count)
    Assert-Like $Error[1].Exception.Message '*FILESTREAM_ON cannot be specified*'
    Assert-False (Test-Table -Name 'CustomFileStreamFileGroup')
}

function Test-ShouldCreateTableWithOptions
{
    Invoke-Pstep -Push 'CreateTableWithOption' -ErrorVariable pstepError -ErrorAction SilentlyContinue
    
    if( $pstepError )
    {
        Assert-Like $pstepError[0] '*Cannot enable compression for object ''AddTableWithOption''*'
    }
    else
    {
        Assert-Table 'AddTableWithOption' -Description 'Testing Add-Table migration' -DataCompression 2
    }
}