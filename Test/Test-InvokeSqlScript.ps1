
function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'InvokeSqlScript' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateBigIntWithNullable
{
    $m = @'
function Push-Migration
{
    Invoke-SqlScript -Path 'AddSchema.sql'
}

function Pop-Migration
{
}

'@ | New-Migration -Name 'InvokeSqlScript'

    $scriptPath = Split-Path -Parent -Path $m
    $scriptPath = Join-Path -Path $scriptPath -ChildPath 'AddSchema.sql'

    @'
create schema [invokesqlscript]
'@ | Set-Content -Path $scriptPath

    Invoke-Rivet -Push 'InvokeSqlScript'

    Assert-Schema 'invokesqlscript'
}


function Test-ShouldFailIfScriptMissing
{
    $m = @'
function Push-Migration
{
    Invoke-SqlScript -Path 'NopeDoNotExist.sql'
    Add-Schema 'invokesqlscript'
}

function Pop-Migration
{
}

'@ | New-Migration -Name 'InvokeSqlScript'

    Invoke-Rivet -Push 'InvokeSqlScript'

    Assert-False (Test-Schema 'invokesqlscript')
}
