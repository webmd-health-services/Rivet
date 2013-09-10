 function New-VarBinaryColumn
    {
        <#
        .SYNOPSIS
        Creates a column object representing an VarBinary datatype.
        #>
        [CmdletBinding(DefaultParameterSetName='Nullable')]
        param(
            [Parameter(Mandatory=$true,Position=0)]
            [string]
            # The column's name.
            $Name,

            [Parameter()]
            [Int]
            # Defines the length
            $Length,

            [Parameter()]
            [Switch]
            # Stores the varbinary(max) data in a filestream data container on the file system.  Requires VarBinary(max)
            $FileStream,

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

        if ($FileStream -and ($Length -ne 0))
        {
            throw ('Column {0}: FileStream requires VarBinary(max)' -f $Name)
            return
        }
        
        $lengthtype = $null

        if ($Length -ne 0)
        {
            $lengthtype = New-Object Rivet.CharacterLength $Length
        }
        else 
        {
            $lengthtype = New-Object Rivet.CharacterLength @()   
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
                [Rivet.Column]::VarBinary($Name, $lengthtype, $FileStream, $nullable, $Default, $Description)
            }
            
            'NotNull'
            {
                [Rivet.Column]::VarBinary($Name,$lengthtype, $FileStream, 'NotNull', $Default, $Description)
            }
        }
    }
    
    Set-Alias -Name 'VarBinary' -Value 'New-VarBinaryColumn'