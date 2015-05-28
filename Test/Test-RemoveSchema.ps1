$floog = ''

function Setup
{
    & (Join-Path $TestDir RivetTest\Import-RivetTest.ps1 -Resolve) -DatabaseName 'Test-RemoveSchema'
    Start-RivetTest
    $floog = 'blarg'
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldRemoveSchema
{
    @'
function Push-Migration()
{
    Add-Schema -Name 'rivetaddremoveschema'
}

function Pop-Migration()
{
    Remove-Schema -Name 'rivetaddremoveschema'
}
'@ | New-Migration -Name 'AddSchema'

    Assert-False (Test-Schema 'rivetaddremoveschema')

    Invoke-Rivet -Push 'AddSchema'

    Assert-True (Test-Schema -Name 'rivetaddremoveschema')

    Invoke-Rivet -Pop -Name 'AddSchema'

    Assert-False (Test-Schema 'AddSchema')
}