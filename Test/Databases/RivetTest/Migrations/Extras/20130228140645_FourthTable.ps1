
function Push-Migration()
{
    Invoke-Query -Query @'
	create table FourthTable (
		id int not null
	)
'@
}

function Pop-Migration()
{
    Invoke-Query -Query @'
	drop table FourthTable
'@
}
