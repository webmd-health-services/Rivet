
function Push-Migration()
{
    Invoke-Query -Query 'insert into InvokeQuery (id) values (1)'

    Invoke-Query -Query @'
	create table TableWithoutColumnsWithColumn (
		id int not null
	)
'@
    Invoke-Query -Query @'
	-- this will give an error
	create table TableWithoutColumns ()
'@
    Invoke-Query -Query 'insert into InvokeQuery (id) values (2)'
}

function Pop-Migration()
{
    Invoke-Query -Query 'delete from InvokeQuery where id = 2'
	
	Invoke-Query -Query 'drop table TableWithoutColumns()'
	
	Invoke-Query -Query 'delete from InvokeQuery where id = 1'

}
