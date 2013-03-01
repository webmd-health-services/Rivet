

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PstepTestSproc]') AND type in (N'P', N'PC'))
	drop procedure [dbo].[PstepTestSproc]
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

CREATE PROCEDURE PstepTestSproc
AS
BEGIN
	select GETDATE()
END

GO
