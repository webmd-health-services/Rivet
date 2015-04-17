function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldInvokeQuery
{
    @"
function Push-Migration
{
    Invoke-Query @'
create function [InvokeQuery] ()
returns int 
begin
 return 1 
end

GO

drop function [InvokeQuery]

'@

    Add-Schema 'Invoke-Query'
}

function Pop-Migration
{
    Remove-Schema 'Invoke-Query'
}

"@ | New-Migration -Name 'CreateInvokeQueryFunction'

    Invoke-Rivet -Push 'CreateInvokeQueryFunction'

    Assert-True (Test-Schema 'Invoke-Query')
}

function Test-ShouldInvokeQueryWithCommentedOutGO
{
    @"
function Push-Migration
{
    Invoke-Query @'
create function [InvokeQuery] ()
returns int 
begin
 return 1 
end

/*
GO
*/

drop function [InvokeQuery]

'@

    Add-Schema 'Invoke-Query'
}

function Pop-Migration
{
    Remove-Function 'InvokeQuery'
    Remove-Schema 'Invoke-Query'
}

"@ | New-Migration -Name 'CreateInvokeQueryFunction'

    Invoke-Rivet -Push 'CreateInvokeQueryFunction' -ErrorAction SilentlyContinue
    Assert-Error

    Assert-False (Test-DatabaseObject -ScalarFunction -Name 'InvokeQuery')
    Assert-False (Test-Schema 'Invoke-Query')
}

function Test-ShouldInvokeCrazyQueries
{
    @"
function Push-Migration
{
    Invoke-Query @'
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
}

"@ | New-Migration -Name 'CreateInvokeQueryFunction'

    Invoke-Rivet -Push 'CreateInvokeQueryFunction' #-ErrorAction SilentlyContinue

    Assert-True (Test-DatabaseObject -StoredProcedure -Name 'RivetTestSproc')
}