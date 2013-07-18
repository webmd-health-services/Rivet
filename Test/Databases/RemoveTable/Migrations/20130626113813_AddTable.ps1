
function Push-Migration()
{
    Add-Table -Name 'Ducati' {
        New-Column 'ID' -Int -Identity 
    } # -SchemaName

}

function Pop-Migration()
{
    Remove-Table -Name 'Ducati'
}
