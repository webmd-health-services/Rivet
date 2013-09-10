 function New-CharColumn
    {
        <#
        .SYNOPSIS
        Creates a column object representing an Char datatype.
        #>
        [CmdletBinding(DefaultParameterSetName='Nullable')]
        param(
            [Parameter(Mandatory=$true,Position=0)]
            [string]
            # The column's name.
            $Name,

            [Parameter()]
            [Int]
            # Defines the string length of the fixed-length string data.  Default is 30
            $Length = 30,

            [Parameter()]
            [string]
            # Controls the code page that is used to store the data
            $Collation,

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
        
        $lengthtype = $null

        $lengthtype = New-Object Rivet.CharacterLength $Length

        switch ($PSCmdlet.ParameterSetName)
        {
            'Nullable'
            {
                $nullable = 'Null'
                if( $Sparse )
                {
                    $nullable = 'Sparse'
                }
                [Rivet.Column]::Char($Name, $lengthtype, $Collation, $nullable, $Default, $Description)
            }
            
            'NotNull'
            {
                [Rivet.Column]::Char($Name,$lengthtype, $Collation, 'NotNull', $Default, $Description)
            }
        }
    }
    
    Set-Alias -Name 'Char' -Value 'New-CharColumn'