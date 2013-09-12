function Push-Migration()
{
    New-UserDefinedFunction -Name 'squarefunction' -Schema 'dbo' -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * @Number) end'
}

function Pop-Migration()
{
}
