$floog = ''

function Setup
{
    & (Join-Path $TestDir RivetTest\Import-RivetTest.ps1 -Resolve) -DatabaseName 'AddRemoveSchema'
    Start-RivetTest
    $floog = 'blarg'
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldCreateSchema
{
    Assert-False (Test-Schema 'rivetaddremoveschema')

    Invoke-Rivet -Push 'AddSchema'

    Assert-True (Test-Schema -Name 'rivetaddremoveschema')
}

function Test-ShouldCreateSchemaWithReservedWord
{
    Assert-False (Test-Schema 'alter')

    Invoke-Rivet -Push 'AddSchemaWithReservedName'

    Assert-True (Test-Schema -Name 'alter')
}

function Test-ShouldAddSchemaWithOwner
{
    Assert-False (Test-Schema 'schemawithowner')
    Invoke-Rivet -Push 'AddSchemaWithOwner'
    $schema = Get-Schema 'schemawithowner'
    Assert-NotNull $schema
    Assert-Equal 'addremoteschema' $schema.principal_name
}

function Test-ShouldRemoveSchema
{
    Assert-False (Test-Schema 'alter')
    Invoke-Rivet -Push 'AddSchemaWithReservedName'
    Assert-True (Test-Schema 'alter')
    Invoke-Rivet -Pop ([int]::MaxValue)
    Assert-False (Test-Schema 'alter')
}