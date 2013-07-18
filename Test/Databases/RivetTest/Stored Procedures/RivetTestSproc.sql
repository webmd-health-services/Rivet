

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

CREATE PROCEDURE RivetTestSproc
AS
BEGIN
	select GETDATE()
END

GO
