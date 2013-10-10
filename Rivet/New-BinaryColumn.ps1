function New-BinaryColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Binary datatype.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter()]
        [Int]
        # Defines the Size
        $Size = 30,

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
        
    $Sizetype = $null

    $Sizetype = New-Object Rivet.CharacterLength $Size

    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::Binary($Name, $Sizetype, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Binary($Name,$Sizetype, 'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'Binary' -Value 'New-BinaryColumn'