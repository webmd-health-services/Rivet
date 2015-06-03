
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
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
    Remove-Schema 'invokesqlscript'
}

'@ | New-Migration -Name 'InvokeSqlScript'

    $scriptPath = Split-Path -Parent -Path $m
    $scriptPath = Join-Path -Path $scriptPath -ChildPath 'AddSchema.sql'

    @'
create schema [invokesqlscript]
'@ | Set-Content -Path $scriptPath

    Invoke-RTRivet -Push 'InvokeSqlScript'

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
    Remove-Schema 'invokesqlscript'
}

'@ | New-Migration -Name 'InvokeSqlScript'

    try
    {
        Invoke-RTRivet -Push 'InvokeSqlScript' -ErrorAction SilentlyContinue

        Assert-False (Test-Schema 'invokesqlscript')
    }
    finally
    {
        @'
function Push-Migration
{
    Add-Schema 'invokesqlscript'
}

function Pop-Migration
{
    Remove-Schema 'invokesqlscript'
}

'@ | Set-Content -Path $m
    }
}

function Test-ShouldSkipEmptyQueries
{
    $m = @'
function Push-Migration
{
    Invoke-SqlScript -Path 'AddSchema.sql'
}

function Pop-Migration
{
    Remove-Schema 'invokesqlscript'
    Remove-Schema 'invokesqlscript2'
}

'@ | New-Migration -Name 'InvokeSqlScript'

    $scriptPath = Split-Path -Parent -Path $m
    $scriptPath = Join-Path -Path $scriptPath -ChildPath 'AddSchema.sql'

    @'
create schema [invokesqlscript]

-- keep these two go statements together
go
go

create schema [invokesqlscript2]

'@ | Set-Content -Path $scriptPath

    Invoke-RTRivet -Push 'InvokeSqlScript'

    Assert-Schema 'invokesqlscript'
    Assert-Schema 'invokesqlscript2'

}

function Test-ShouldSupportNonQueryParameter
{
    $m = @'
function Push-Migration
{
    Invoke-SqlScript -Path 'AddSchema.sql' -NonQuery
}

function Pop-Migration
{
    Remove-Schema 'invokesqlscript'
}

'@ | New-Migration -Name 'InvokeSqlScript'

    $scriptPath = Split-Path -Parent -Path $m
    $scriptPath = Join-Path -Path $scriptPath -ChildPath 'AddSchema.sql'

    @'
create schema [invokesqlscript]
'@ | Set-Content -Path $scriptPath

    Invoke-RTRivet -Push 'InvokeSqlScript'

    Assert-Schema 'invokesqlscript'
}


function Test-ShouldSupportScalarParameter
{
    $m = @'
function Push-Migration
{
    Invoke-SqlScript -Path 'AddSchema.sql' -AsScalar
}

function Pop-Migration
{
    Remove-Schema 'invokesqlscript'
}

'@ | New-Migration -Name 'InvokeSqlScript'

    $scriptPath = Split-Path -Parent -Path $m
    $scriptPath = Join-Path -Path $scriptPath -ChildPath 'AddSchema.sql'

    @'
create schema [invokesqlscript]
'@ | Set-Content -Path $scriptPath

    Invoke-RTRivet -Push 'InvokeSqlScript'

    Assert-Schema 'invokesqlscript'
}

