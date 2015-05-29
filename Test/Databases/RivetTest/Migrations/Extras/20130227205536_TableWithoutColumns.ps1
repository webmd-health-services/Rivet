
function Push-Migration()
{
    Add-Row -TableName 'InvokeQuery' -Column @{ 'id' = '1' }

    Add-Table TableWithoutColumnsWithColumn {
        int 'id' -NotNull
	}
  
    Add-Table 'TableWithoutColumns' {
    }

    Add-Row 'InvokeQuery' -Column @{ 'id' = '2' }
}

function Pop-Migration()
{
    Remove-Row -TableName 'InvokeQuery' -Where 'id = 2'
	
    Remove-Table 'TableWithoutColumns'
	
    Remove-Row -TableName 'InvokeQuery' -Where 'id = 2'
}
