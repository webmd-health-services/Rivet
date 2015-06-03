
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
$floog = ''

function Start-Test
{
    Start-RivetTest
    $floog = 'blarg'
}

function Stop-Test
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

    Invoke-RTRivet -Push 'AddSchema'

    Assert-True (Test-Schema -Name 'rivetaddremoveschema')

    Invoke-RTRivet -Pop -Name 'AddSchema'

    Assert-False (Test-Schema 'AddSchema')
}
