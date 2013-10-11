function New-DateColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Date datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Members' {
            Date 'Birthday'
        }

    ## ALIASES

     * Date

    .EXAMPLE
    Add-Table 'Members' { New-DateColumn 'Birthday' -NotNull }

    Demonstrates how to create a required `date` column.

    .EXAMPLE
    Add-Table 'Members' { Date 'Birthday' -Sparse }

    Demonstrate show to create a nullable, sparse `date` column when adding a new table.

    .EXAMPLE
    Add-Table 'Members' { Date 'Birthday' -NotNull -Default 'get`date`()' }
    
    Demonstrates how to create a `date` column with a default value, in this case the current `date`.  (You alwyas use UTC `date`s, right?)  Probably not a great example, setting someone's birthday to the current `date`. Reasons are left as an exercise for the reader.

    .EXAMPLE
    Add-Table 'Members' { Date 'Birthday' -Description 'The members birthday.' }

    Demonstrates how to create an optional `date` column with a description.
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

    if ($NotNull -and $Sparse)
    {
        throw ('Column {0}: A column cannot be NOT NULL and SPARSE.  Please choose one, but not both' -f $Name)
        return
    }
        
    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::Date($Name, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Date($Name,'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'Date' -Value 'New-DateColumn'