 function New-FloatColumn
    {
        <#
        .SYNOPSIS
        Creates a column object representing an Float datatype.
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

            [Parameter(Mandatory=$true)]
            [Int]
            # Maximum total number of Numeric digits that will be stored
            $Precision,

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

        $dataSize = New-Object Rivet.PrecisionScale $Precision
        
        switch ($PSCmdlet.ParameterSetName)
        {
            'Nullable'
            {
                $nullable = 'Null'
                if( $Sparse )
                {
                    $nullable = 'Sparse'
                }
                [Rivet.Column]::Float($Name, $dataSize, $nullable, $Default, $Description)
            }
            
            'NotNull'
            {
                [Rivet.Column]::Float($Name, $dataSize, 'NotNull', $Default, $Description)
            }
        }
    }
    
    Set-Alias -Name 'Float' -Value 'New-FloatColumn'