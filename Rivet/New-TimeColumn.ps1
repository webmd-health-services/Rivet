 function New-TimeColumn
    {
        <#
        .SYNOPSIS
        Creates a column object representing an Time datatype.
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
            [Int]
            # The number of decimal digits that will be stored to the right of the decimal point
            $Scale = 0,

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

        $dataSize = $null

        $dataSize = New-Object Rivet.PrecisionScale $Scale
        
        switch ($PSCmdlet.ParameterSetName)
        {
            'Nullable'
            {
                $nullable = 'Null'
                if( $Sparse )
                {
                    $nullable = 'Sparse'
                }
                [Rivet.Column]::Time($Name, $dataSize, $nullable, $Default, $Description)
            }
            
            'NotNull'
            {
                [Rivet.Column]::Time($Name,$dataSize, 'NotNull', $Default, $Description)
            }
        }
    }
    
    Set-Alias -Name 'Time' -Value 'New-TimeColumn'