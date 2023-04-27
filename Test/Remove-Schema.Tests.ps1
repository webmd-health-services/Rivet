
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

    $script:floog = ''
}

Describe 'Remove-Schema' {
    BeforeEach {
        Start-RivetTest
        $script:floog = 'blarg'
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should remove schema' {
        @'
    function Push-Migration()
    {
        Add-Schema -Name 'rivetaddremoveschema'
    }

    function Pop-Migration()
    {
        Remove-Schema -Name 'rivetaddremoveschema'
    }
'@ | New-TestMigration -Name 'AddSchema'

        (Test-Schema 'rivetaddremoveschema') | Should -BeFalse

        Invoke-RTRivet -Push 'AddSchema'

        (Test-Schema -Name 'rivetaddremoveschema') | Should -BeTrue

        Invoke-RTRivet -Pop -Name 'AddSchema'

        (Test-Schema 'AddSchema') | Should -BeFalse
    }
}
