
function Start-Test
{
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Split-SqlBatchQuery.ps1' -Resolve)
}

function Stop-Test
{
    Remove-Item 'function:Split-SqlBatchQuery'
}

function Test-ShouldSplitBatch
{
    
    $query1 = @"
create function [InvokeQuery] ()
returns int 
begin
 return 1 
end
"@

    $query2 = @"
drop function [InvokeQuery]
"@ 

    $query = @"
$query1

GO

$query2
"@

    $result = Split-SqlBatchQuery -Query $query
    Assert-Equal $result[0] $query1
    Assert-Equal $result[1] $query2
}

function Test-ShouldSplitBatchWithCommentedOutGO
{
    $query = @'
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

    $result = $query | Split-SqlBatchQuery 
    Assert-Equal $query $result
}

function Test-ShouldSplitCrazyQueries
{
    $query1 = @'
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RivetTestSproc]') AND type in (N'P', N'PC'))
	drop procedure [dbo].[RivetTestSproc]
'@

    $ignoredStuff = @'
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
'@

    $query2 = @'
--go
CREATE PROCEDURE RivetTestSproc
AS
BEGIN
	select GETDATE()
END
'@

    $query3 = @"
declare @str varchar(max)

select @str = '
Hello
world
GO
'

select @str
"@
    $query = @"
$query1
go
$ignoredStuff
$query2

GO

$query3
"@
    $result = Split-SqlBatchQuery $query -Verbose
    Assert-Equal $query1 $result[0]
    Assert-Equal $query2 $result[2]
    Assert-Equal $query3 $result[3]
}

function Test-ShouldSplitWithNestedString
{
    $query = @'
if object_id('rivet.InsertMigration', 'P') is null 
    exec sp_executesql N'
        create procedure [rivet].[InsertMigration]
	        @ID bigint,
	        @Name varchar(50),
	        @Who varchar(50),
	        @ComputerName varchar(50)
        as
        begin
	        declare @AtUtc datetime2(7)
	        select @AtUtc = getutcdate()
	        insert into [rivet].[Migrations] ([ID],[Name],[Who],[ComputerName],[AtUtc]) values (@ID,@Name,@Who,@ComputerName,@AtUtc)
	        insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values (''Push'',@ID,@Name,@Who,@ComputerName,@AtUtc)
        end
    '
'@

    $result = Split-SqlBatchQuery $query
    Assert-Equal $query $result    
}

function Test-ShouldSplitWithVariableSetToEmptyString
{
    $query = @'
DECLARE @EmptyGoal Varchar(3000)

SET @EmptyGoal = ''

Select @EmptyGoal
'@

    $result = Split-SqlBatchQuery $query
    Assert-Equal $query $result    
}

function Test-ShouldIgnoreAnythingInSingleLineComments
{
    $query = @'
DECLARE @EmptyGoal Varchar(3000)

-- Let's ignore that apostrophe

Select @EmptyGoal
'@

    $result = Split-SqlBatchQuery $query 
    Assert-Equal $query $result    
}