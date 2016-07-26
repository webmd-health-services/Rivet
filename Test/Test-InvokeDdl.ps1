
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldInvokeDdl
{
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

    Assert-True (Test-Schema 'Invoke-Ddl')
}

function Test-ShouldInvokeDdlWithCommentedOutGO
{
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

    Invoke-RTRivet -Push 'CreateInvokeDdlFunction' -ErrorAction SilentlyContinue
    Assert-Error

    Assert-False (Test-DatabaseObject -ScalarFunction -Name 'InvokeDdl')
    Assert-False (Test-Schema 'Invoke-Ddl')
}

function Test-ShouldInvokeCrazyQueries
{
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

    Assert-True (Test-DatabaseObject -StoredProcedure -Name 'RivetTestSproc')
}
