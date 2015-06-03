
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRejectMigrationsWithNamesThatAreTooLong
{
    $name = 'a' * 242

    try
    {
        @'
function Push-Migration
{
    Add-Table Foobar {
        BigInt ID
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name $name
        Fail 'Didn''t throw an exception with a name that''s too long.'
    }
    catch
    {
        $ex = $_.Exception
        Assert-Equal 'System.Management.Automation.ParameterBindingValidationException' $ex.GetType().FullName 
        Assert-Match $ex.Message 'parameter ''Name'''
        Assert-Match $ex.Message 'is too long'
    }
}

function Test-ShouldAllowLongMigrationNames
{
    $migrationPathLength = $RTDatabaseMigrationRoot.Length
    # remove length of the separator, timestamp, underscore and extension
    $name = 'a' * (259 - $migrationPathLength - 1 - 14 - 1 - 4)

    @'
function Push-Migration
{
    Add-Table Foobar {
        BigInt ID
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name $name

    Invoke-Rivet -Push
    Assert-NoError
    Assert-True (Test-Table 'Foobar')
}
