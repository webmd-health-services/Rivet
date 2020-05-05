function New-HierarchyIDColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an HierarchyID datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'FamilyTree' {
            HierarchyID 'Father'
        }

    ## ALIASES

     * HierarchyID

    .EXAMPLE
    Add-Table 'FamilyTree' { HierarchyID 'Father' }

    Demonstrates how to create an optional `hierarchyid` column called `Father`.

    .EXAMPLE
    Add-Table 'FamilyTree' { HierarchyID 'Father' -NotNull }

    Demonstrates how to create a required `hierarchyid` column called `Father`.

    .EXAMPLE
    Add-Table 'FamilyTree' { HierarchyID 'Father' -Sparse }

    Demonstrates how to create a sparse, optional `hierarchyid` column called `Father`.

    .EXAMPLE
    Add-Table 'FamilyTree' { HierarchyID 'Father' -NotNull -Description "The hierarchy ID of this person's father." }

    Demonstrates how to create a required `hierarchyid` column with a description.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Mandatory,ParameterSetName='NotNull')]
        # Don't allow `NULL` values in this column.
        [switch]$NotNull,

        [Parameter(ParameterSetName='Nullable')]
        # Store nulls as Sparse.
        [switch]$Sparse,

        # A SQL Server expression for the column's default value 
        [String]$Default,

        # The name of the default constraint for the column's default expression. Required if the Default parameter is given.
        [String]$DefaultConstraintName,
            
        # A description of the column.
        [String]$Description
    )
        
    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::HierarchyID($Name, $nullable, $Default, $DefaultConstraintName, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::HierarchyID($Name,'NotNull', $Default, $DefaultConstraintName, $Description)
        }
    }
}
    
Set-Alias -Name 'HierarchyID' -Value 'New-HierarchyIDColumn'