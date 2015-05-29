
function Push-Migration()
{
    Add-Table PushSucceedsPopFails {
		int 'id' -NotNull
	}
}

function Pop-Migration()
{
    Remove-Table 'PopSucceedsPushFails'
}
