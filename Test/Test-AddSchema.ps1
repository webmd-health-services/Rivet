$floog = ''

function Setup
{
    & (Join-Path $TestDir RivetTest\Import-RivetTest.ps1 -Resolve) -DatabaseName 'Test-AddSchema'
    Start-RivetTest
    $floog = 'blarg'
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldCreateSchema
{
    @'
function Push-Migration()
{
    Add-Schema -Name 'rivetaddremoveschema'
    # Check that Add-Schema is idempotent.
    Add-Schema -Name 'rivetaddremoveschema'
}

function Pop-Migration()
{
    Remove-Schema -Name 'rivetaddremoveschema'
}
'@ | New-Migration -Name 'addschema'

    Assert-False (Test-Schema 'rivetaddremoveschema')

    Invoke-Rivet -Push 'AddSchema'

    Assert-True (Test-Schema -Name 'rivetaddremoveschema')
}

function Test-ShouldCreateSchemaWithReservedWord
{
    @'
function Push-Migration()
{
    Add-Schema -Name 'alter'
}

function Pop-Migration()
{
    Remove-Schema -Name 'alter'
}
'@ | New-Migration -Name 'AddSchemaWithReservedName'

    Assert-False (Test-Schema 'alter')

    Invoke-Rivet -Push 'AddSchemaWithReservedName'

    Assert-True (Test-Schema -Name 'alter')
}

function Test-ShouldAddSchemaWithOwner
{
    @'

function Push-Migration
{
    Invoke-Query 'create user addremoteschema without login'
    Add-Schema -Name 'schemawithowner' -Authorization 'addremoteschema'
}

function Pop-Migration
{
    Remove-Schema -Name 'schemawithowner'
    Invoke-Query 'drop user addremoteschema'
}
'@ | New-Migration -Name 'AddSchemaWithOwner'

    Assert-False (Test-Schema 'schemawithowner')
    Invoke-Rivet -Push 'AddSchemaWithOwner'
    $schema = Get-Schema 'schemawithowner'
    Assert-NotNull $schema
    Assert-Equal 'addremoteschema' $schema.principal_name
}
