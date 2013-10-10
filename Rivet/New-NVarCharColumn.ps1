function New-NVarCharColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an NVarChar datatype.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter()]
        [Int]
        # Defines the string Size of the fixed-Size string data.  Default is 30
        $Size,

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
        
        $Sizetype = $null

    if ($Size -ne 0)
    {
        $Sizetype = New-Object Rivet.CharacterLength $Size
    }
    else 
    {
        $Sizetype = New-Object Rivet.CharacterLength @()   
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
            [Rivet.Column]::NVarChar($Name, $Sizetype, $Collation, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::NVarChar($Name,$Sizetype, $Collation, 'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'NVarChar' -Value 'New-NVarCharColumn'