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
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Mandatory=$true,ParameterSetName='NotNull')]
        [Switch]
        # Don't allow `NULL` values in this column.
        $NotNull,

        [Parameter(ParameterSetName='Nullable')]
        [Switch]
        # Store nulls as Sparse.
        $Sparse,

        [Parameter()]
        [string]
        # A SQL Server expression for the column's default value 
        $Default,
            
        [Parameter()]
        [string]
        # A description of the column.
        $Description
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
            [Rivet.Column]::HierarchyID($Name, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::HierarchyID($Name,'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'HierarchyID' -Value 'New-HierarchyIDColumn'