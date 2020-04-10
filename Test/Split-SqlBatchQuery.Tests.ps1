
Describe 'Split-SqlBatchQuery' {
    BeforeEach {
        . (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Functions\Split-SqlBatchQuery.ps1' -Resolve)
    }

    AfterEach {
        Remove-Item 'function:Split-SqlBatchQuery'
    }

    It 'should split batch' {
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
        $result[0] | Should Be $query1
        $result[1] | Should Be $query2
    }

    It 'should split batch with commented out g o' {
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
        $result | Should Be $query
    }

    It 'should split crazy queries' {
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
        $result[0] | Should Be $query1
        $result[2] | Should Be $query2
        $result[3] | Should Be $query3
    }

    It 'should split with nested string' {
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
        $result | Should Be $query
    }

    It 'should split with variable set to empty string' {
        $query = @'
DECLARE @EmptyGoal Varchar(3000)

SET @EmptyGoal = ''

Select @EmptyGoal
'@

        $result = Split-SqlBatchQuery $query
        $result | Should Be $query
    }

    It 'should ignore anything in single line comments' {
        $query = @'
DECLARE @EmptyGoal Varchar(3000)

-- Let's ignore that apostrophe

Select @EmptyGoal
'@

        $result = Split-SqlBatchQuery $query 
        $result | Should Be $query
    }

    It 'should ignore string that ends in escaped quote' {
        $query = @'
IF OBJECT_ID(N'[dbo].[GetFeatureActivationsBySponsor]') IS NULL 
    EXEC (N'CREATE PROCEDURE [dbo].[GetFeatureActivationsBySponsor] AS select col1 = ''StubColumn''')
'@

        $result = Split-SqlBatchQuery $query
        $result | Should Be $query
    }

    It 'should handle go at end of query' {
        $query = @'
IF OBJECT_ID(N'[dbo].[GetFeatureActivationsBySponsor]') IS NULL 
    EXEC (N'CREATE PROCEDURE [dbo].[GetFeatureActivationsBySponsor] AS select col1 = ''StubColumn''')

'@

        $result = Split-SqlBatchQuery ("{0}GO`n" -f $query)
        $result | Should Be $query
    }

    It 'should parse really scary embedded string' {
        $query = @"
SET @SQL = '
AND a.name = ''' + @tablename + '''
END
'

"@

        $result = Split-SqlBatchQuery ("{0}GO`n" -f $query)
        $result | Should Be $query
    }
}
