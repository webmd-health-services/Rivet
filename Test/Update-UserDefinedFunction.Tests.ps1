
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Update-UserDefinedFunction' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should update user defined function' {
        @'
    function Push-Migration
    {
        Add-UserDefinedFunction -Name 'squarefunction' -Schema 'dbo' -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * @Number) end'
        Update-UserDefinedFunction -Name 'squarefunction' -Schema 'dbo' -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * (@Number)) end'
    }

    function Pop-Migration
    {
        Remove-UserDefinedFunction -Name 'squarefunction'
    }

'@ | New-TestMigration -Name 'UpdateUserDefinedFunction'

        Invoke-RTRivet -Push 'UpdateUserDefinedFunction'

        Assert-UserDefinedFunction -Name 'squarefunction' -Schema 'dbo' -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * (@Number)) end'
    }
}
