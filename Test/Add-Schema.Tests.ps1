
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

   $script:floog = ''
}

Describe 'Add-Schema' {
    BeforeEach {
        Start-RivetTest
        $floog = 'blarg'
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create schema' {
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
'@ | New-TestMigration -Name 'addschema'

        (Test-Schema 'rivetaddremoveschema') | Should -BeFalse

        Invoke-RTRivet -Push 'AddSchema'

        (Test-Schema -Name 'rivetaddremoveschema') | Should -BeTrue
    }

    It 'should create schema with reserved word' {
        @'
    function Push-Migration()
    {
        Add-Schema -Name 'alter'
    }

    function Pop-Migration()
    {
        Remove-Schema -Name 'alter'
    }
'@ | New-TestMigration -Name 'AddSchemaWithReservedName'

        (Test-Schema 'alter') | Should -BeFalse

        Invoke-RTRivet -Push 'AddSchemaWithReservedName'

        (Test-Schema -Name 'alter') | Should -BeTrue
    }

    It 'should add schema with owner' {
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
'@ | New-TestMigration -Name 'AddSchemaWithOwner'

        (Test-Schema 'schemawithowner') | Should -BeFalse
        Invoke-RTRivet -Push 'AddSchemaWithOwner'
        $schema = Get-Schema 'schemawithowner'
        $schema | Should -Not -BeNullOrEmpty
        $schema.principal_name | Should -Be 'addremoteschema'
    }
}
