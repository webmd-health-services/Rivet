
function Get-DefaultConstraint
{
    <#
    .SYNOPSIS
    Contains a row for each object that is a default definition (created as part of a CREATE TABLE or ALTER TABLE statement instead of a CREATE DEFAULT statement), with sys.objects.type = D.
    #>

    $query = @'
    select * 
    from sys.default_constraints
'@
    
    Invoke-RivetTestQuery -Query $query

}