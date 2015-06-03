$floog = ''

& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
    $floog = 'blarg'
}

function Stop-Test
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

    Invoke-RTRivet -Push 'AddSchema'

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

    Invoke-RTRivet -Push 'AddSchemaWithReservedName'

    Assert-True (Test-Schema -Name 'alter')
}

function Test-ShouldAddSchemaWithOwner
{
    @'

function Push-Migration
{
    Invoke-Ddl 'create user addremoteschema without login'
    Add-Schema -Name 'schemawithowner' -Authorization 'addremoteschema'
}

function Pop-Migration
{
    Remove-Schema -Name 'schemawithowner'
    Invoke-Ddl 'drop user addremoteschema'
}
'@ | New-Migration -Name 'AddSchemaWithOwner'

    Assert-False (Test-Schema 'schemawithowner')
    Invoke-RTRivet -Push 'AddSchemaWithOwner'
    $schema = Get-Schema 'schemawithowner'
    Assert-NotNull $schema
    Assert-Equal 'addremoteschema' $schema.principal_name
}
