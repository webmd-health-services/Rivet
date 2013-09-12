
function Push-Migration()
{
    Add-Table -Name 'Ducati' {
        Int 'ID' -Identity 
    } # -SchemaName

}

function Pop-Migration()
{
    Remove-Table -Name 'Ducati'
}
