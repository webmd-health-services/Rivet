function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'UpdateDatabase' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRejectMigrationsWithNamesThatAreTooLong
{
    $name = 'a' * 51
    @'
function Push-Migration
{
    Add-Table Foobar {
        BigInt ID
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name $name

    Invoke-Rivet -Push -ErrorAction SilentlyContinue
    Assert-False (Test-Table 'Foobar')
    Assert-Error -Last 'too long'
}
