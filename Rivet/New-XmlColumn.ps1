function New-XmlColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Xml datatype.
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
        [switch]
        # Specifies that this is a well-formed XML document instead of XML fragment
        $Document,

        [Parameter(Mandatory=$true)]
        [string]
        # Name of an XML schema collection
        $XmlSchemaCollection,

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

    if ($Document -and -not $XmlSchemaCollection)
    {
        throw ('Column {0}: A XmlSchemaCollection name needs to be specified for well-formed XML documents.' -f $Name)
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
            [Rivet.Column]::Xml($Name, $Document, $XmlSchemaCollection, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Xml($Name, $Document, $XmlSchemaCollection, 'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'Xml' -Value 'New-XmlColumn'