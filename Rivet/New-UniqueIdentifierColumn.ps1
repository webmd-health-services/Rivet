 function New-UniqueIdentifierColumn
    {
        <#
        .SYNOPSIS
        Creates a column object representing an UniqueIdentifier datatype.
        #>
        [CmdletBinding(DefaultParameterSetName='Nullable')]
        param(
            [Parameter(Mandatory=$true,Position=0)]
            [string]
            # The column's name.
            $Name,

            [Parameter()]
            [Switch]
            # Sets RowGuidCol
            $RowGuidCol,

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
                [Rivet.Column]::UniqueIdentifier($Name, $RowGuidCol, $nullable, $Default, $Description)
            }
            
            'NotNull'
            {
                [Rivet.Column]::UniqueIdentifier($Name, $RowGuidCol, 'NotNull', $Default, $Description)
            }
        }
    }
    
    Set-Alias -Name 'UniqueIdentifier' -Value 'New-UniqueIdentifierColumn'