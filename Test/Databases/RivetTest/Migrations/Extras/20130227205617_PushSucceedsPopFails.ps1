
function Push-Migration()
{
    Invoke-Query -Query @'
	create table PushSucceedsPopFails(
		id int not null
	)
'@
}

function Pop-Migration()
{
    Invoke-Query -Query @'
	-- This table doesn''t exist
	drop table PopSucceedsPushFails 
'@
}
