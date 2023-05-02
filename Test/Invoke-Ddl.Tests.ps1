
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Invoke-Ddl' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should invoke ddl' {
        @"
    function Push-Migration
    {
        Invoke-Ddl @'
    create function [InvokeDdl] ()
    returns int
    begin
     return 1
    end

    GO

    drop function [InvokeDdl]

'@

        Add-Schema 'Invoke-Ddl'
    }

    function Pop-Migration
    {
        Remove-Schema 'Invoke-Ddl'
    }

"@ | New-TestMigration -Name 'CreateInvokeDdlFunction'

        Invoke-RTRivet -Push 'CreateInvokeDdlFunction'

        (Test-Schema 'Invoke-Ddl') | Should -BeTrue
    }

    It 'should invoke ddl with commented out go' {
        @"
    function Push-Migration
    {
        Invoke-Ddl @'
    create function [InvokeDdl] ()
    returns int
    begin
     return 1
    end

    /*
    GO
    */

    drop function [InvokeDdl]

'@

        Add-Schema 'Invoke-Ddl'
    }

    function Pop-Migration
    {
        Remove-Schema 'Invoke-Ddl'
    }

"@ | New-TestMigration -Name 'CreateInvokeDdlFunction'

        { Invoke-RTRivet -Push 'CreateInvokeDdlFunction' } | Should -Throw '*incorrect syntax*'
        (Test-DatabaseObject -ScalarFunction -Name 'InvokeDdl') | Should -BeFalse
        (Test-Schema 'Invoke-Ddl') | Should -BeFalse
    }

    It 'should invoke crazy queries' {
        @"
    function Push-Migration
    {
        Invoke-Ddl @'
    IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RivetTestSproc]') AND type in (N'P', N'PC'))
    	drop procedure [dbo].[RivetTestSproc]
    go

    /*
    Nested
    	/* comment
    	*/
    with a go
    go
    */

    --superfluous GO statements
    	go
        go

    go -- comment
    go-- really friendly comment
    --go

    CREATE PROCEDURE RivetTestSproc
    AS
    BEGIN
    	select GETDATE()
    END

    GO
'@
    }

    function Pop-Migration
    {
        Remove-StoredProcedure 'RivetTestSproc'
    }

"@ | New-TestMigration -Name 'CreateInvokeDdlFunction'

        Invoke-RTRivet -Push 'CreateInvokeDdlFunction' #-ErrorAction SilentlyContinue

        (Test-DatabaseObject -StoredProcedure -Name 'RivetTestSproc') | Should -BeTrue
    }
}
