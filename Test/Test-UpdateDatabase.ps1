function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'UpdateDatabase'
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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

    $Error.Clear()
    Invoke-Rivet -Push -ErrorAction SilentlyContinue
    Assert-False (Test-Table 'Foobar')
    Assert-Equal 1 $Error.Count
    Assert-Like $Error[0].Exception.Message '*too long*'
}
