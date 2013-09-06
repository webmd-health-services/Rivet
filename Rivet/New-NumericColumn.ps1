 function New-NumericColumn
    {
        <#
        .SYNOPSIS
        Creates a column object representing an Numeric datatype.
        #>
        [CmdletBinding(DefaultParameterSetName='Nullable')]
        param(
            [Parameter(Mandatory=$true,Position=0)]
            [string]
            # The column's name.
            $Name,

            [Parameter(Mandatory=$true,ParameterSetName='Identity')]
            [Parameter(Mandatory=$true,ParameterSetName='IdentityWithSeed')]
            [Switch]
            # The column should be an identity.
            $Identity,

            [Parameter(Mandatory=$true,ParameterSetName='IdentityWithSeed',Position=1)]
            [int]
            # The starting value for the identity.
            $Seed,

            [Parameter(Mandatory=$true,ParameterSetName='IdentityWithSeed',Position=2)]
            [int]
            # The increment between auto-generated identity values.
            $Increment,

            [Parameter(ParameterSetName='Identity')]
            [Parameter(ParameterSetName='IdentityWithSeed')]
            [Switch]
            # Stops the identity from being replicated.
            $NotForReplication,

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
            [Int]
            # The number of Numeric digits that will be stored to the right of the Numeric point
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

        $dataSize = New-Object Rivet.PrecisionScale $Precision, $Scale

        switch ($PSCmdlet.ParameterSetName)
        {
            'Nullable'
            {
                $nullable = 'Null'
                if( $Sparse )
                {
                    $nullable = 'Sparse'
                }
                [Rivet.Column]::Numeric($Name, $dataSize, $nullable, $Default, $Description)
            }
            
            'NotNull'
            {
                [Rivet.Column]::Numeric($Name, $dataSize, 'NotNull', $Default, $Description)
            }

            'Identity'
            {
                $i = New-Object 'Rivet.Identity' $NotForReplication
                [Rivet.Column]::Numeric( $Name, $dataSize, $i, $Description )
            }

            'IdentityWithSeed'
            {
                $i = New-Object 'Rivet.Identity' $Seed, $Increment, $NotForReplication
                [Rivet.Column]::Numeric( $Name, $dataSize, $i, $Description )
            }

            
        }
    }
    
    Set-Alias -Name 'Numeric' -Value 'New-NumericColumn'