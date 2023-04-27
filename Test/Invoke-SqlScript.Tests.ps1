
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Invoke-SqlScript' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create big int with nullable' {
        $m = @'
    function Push-Migration
    {
        Invoke-SqlScript -Path 'AddSchema.sql'
    }

    function Pop-Migration
    {
        Remove-Schema 'invokesqlscript'
    }

'@ | New-TestMigration -Name 'InvokeSqlScript'

        $scriptPath = Split-Path -Parent -Path $m
        $scriptPath = Join-Path -Path $scriptPath -ChildPath 'AddSchema.sql'

        @'
    create schema [invokesqlscript]
'@ | Set-Content -Path $scriptPath

        Invoke-RTRivet -Push 'InvokeSqlScript'

        Assert-Schema 'invokesqlscript'
    }


    It 'should fail if script missing' {
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

'@ | New-TestMigration -Name 'InvokeSqlScript'

        try
        {
            Invoke-RTRivet -Push 'InvokeSqlScript' -ErrorAction SilentlyContinue

            (Test-Schema 'invokesqlscript') | Should -BeFalse
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

    It 'should skip empty queries' {
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

'@ | New-TestMigration -Name 'InvokeSqlScript'

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

    It 'should support non query parameter' {
        $m = @'
    function Push-Migration
    {
        Invoke-SqlScript -Path 'AddSchema.sql' -NonQuery
    }

    function Pop-Migration
    {
        Remove-Schema 'invokesqlscript'
    }

'@ | New-TestMigration -Name 'InvokeSqlScript'

        $scriptPath = Split-Path -Parent -Path $m
        $scriptPath = Join-Path -Path $scriptPath -ChildPath 'AddSchema.sql'

        @'
    create schema [invokesqlscript]
'@ | Set-Content -Path $scriptPath

        Invoke-RTRivet -Push 'InvokeSqlScript'

        Assert-Schema 'invokesqlscript'
    }


    It 'should support scalar parameter' {
        $m = @'
    function Push-Migration
    {
        Invoke-SqlScript -Path 'AddSchema.sql' -AsScalar
    }

    function Pop-Migration
    {
        Remove-Schema 'invokesqlscript'
    }

'@ | New-TestMigration -Name 'InvokeSqlScript'

        $scriptPath = Split-Path -Parent -Path $m
        $scriptPath = Join-Path -Path $scriptPath -ChildPath 'AddSchema.sql'

        @'
    create schema [invokesqlscript]
'@ | Set-Content -Path $scriptPath

        Invoke-RTRivet -Push 'InvokeSqlScript'

        Assert-Schema 'invokesqlscript'
    }
}
