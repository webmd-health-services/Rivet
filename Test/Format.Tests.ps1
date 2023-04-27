
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Format' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should write sql script to output without error' {
        $m = @'
    function Push-Migration
    {
        Invoke-SqlScript -Path 'ShouldWriteToOutputWithoutError.sql'
    }

    function Pop-Migration
    {
        Remove-StoredProcedure 'ShouldWriteToOutputWithoutError'
    }

'@ | New-TestMigration -Name 'ShouldWriteToOutputWithoutError'

        $scriptPath = Split-Path -Parent -Path $m
        $scriptPath = Join-Path -Path $scriptPath -ChildPath 'ShouldWriteToOutputWithoutError.sql'

     @'
    SET QUOTED_IDENTIFIER ON
    SET ANSI_NULLS ON
    GO

    IF OBJECT_ID('dbo.ShouldWriteToOutputWithoutError') IS NULL
    	EXEC (N'CREATE PROCEDURE dbo.ShouldWriteToOutputWithoutError AS SELECT col1 = ''StubColumn''')

    GO

    ALTER PROCEDURE dbo.ShouldWriteToOutputWithoutError
    AS
    BEGIN

        SELECT col1 = 'StubColumn2'
    END
'@ | Set-Content -Path $scriptPath

        $op = Invoke-RTRivet -Push 'ShouldWriteToOutputWithoutError'
        $op | Format-Table
        $Global:Error.Count | Should -Be 0
    }
}
