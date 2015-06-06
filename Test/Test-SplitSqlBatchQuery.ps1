
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
$($query1)GO
$query2
"@

    $result = Split-SqlBatchQuery -Query $query
    Assert-Equal $query1 $result[0]
    Assert-Equal $query2 $result[1]
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
$($query1)go

$ignoredStuff
$($query2)GO
$query3
"@
    $result = Split-SqlBatchQuery $query | Where-Object { $_.Trim() }
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


function Test-ShouldIgnoreStringThatEndsInEscapedQuote
{
    $query = @'
IF OBJECT_ID(N'[dbo].[GetFeatureActivationsBySponsor]') IS NULL 
	EXEC (N'CREATE PROCEDURE [dbo].[GetFeatureActivationsBySponsor] AS select col1 = ''StubColumn''')
'@

    $result = Split-SqlBatchQuery $query
    Assert-Equal $query $result    
}

function Test-ShouldHandleGoAtEndOfQuery
{
    $query = @'
IF OBJECT_ID(N'[dbo].[GetFeatureActivationsBySponsor]') IS NULL 
	EXEC (N'CREATE PROCEDURE [dbo].[GetFeatureActivationsBySponsor] AS select col1 = ''StubColumn''')

'@

    $result = Split-SqlBatchQuery ("{0}GO`n" -f $query)
    Assert-Equal $query $result    
}

function Test-ShouldParseReallyScaryEmbeddedString
{
    $query = @"
SET @SQL = '
AND a.name = ''' + @tablename + '''
END
'

"@

    $result = Split-SqlBatchQuery ("{0}GO`n" -f $query)
    Assert-Equal $query $result    
}

function Ignore-ShouldSplitCurrentCodeObjects
{
    Get-ChildItem -Path 'F:\Build\PHMA\Production\Database\Change Scripts\*\*\*.sql' |
        ForEach-Object {
            $path = $_.FullName
            Write-Verbose $path #-Verbose

            $expectedContent = Get-Content -LiteralPath $path -Raw 
            if( -not $expectedContent )
            {
                Write-Warning ('File ''{0}'' is empty.' -f $path)
                return
            }

            do
            {
                $expectedContent = $expectedContent.Trim()
                $expectedContent = $expectedContent -replace "`nGO$","`n"
            }
            while( $expectedContent -match "`nGO\s*$" )

            if( -not $expectedContent )
            {
                Write-Warning ('File ''{0}'' is empty.' -f $path)
                return
            }

            # make sure all GO statements are GO`r`n
            $expectedContent = $expectedContent -replace "`n[ \t]*GO[ \t]*`r?`n","`nGO`r`n"
 
            $splitContent = $expectedContent | Split-SqlBatchQuery
            $splitContent = $splitContent -join "GO`r`n"

            #try
            #{
                Assert-Equal $expectedContent.ToLower() $splitContent.ToLower()  $path
            #}
            #catch
            #{
            #    $path
            #}
            #}

        } | 
        Write-Error

}
