function New-XmlColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Xml datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table -Name 'WebConfigs' -Column {
            Xml 'WebConfig' -XmlSchemaCollection 'webconfigschema'
        }

    Remember you have to have already created the XML schema before creating a column that uses it.

    ## ALIASES

     * Xml

    .EXAMPLE
    Add-Table 'WebConfigs' { Xml 'WebConfig' -XmlSchemaCollection 'webconfigschema' } 

    Demonstrates how to create an optional `xml` column which uses the `webconfigschema` schema collection.

    .EXAMPLE
    Add-Table 'WebConfigs' { Xml 'WebConfig' -XmlSchemaCollection 'webconfigschema' -NotNull }

    Demonstrates how to create a required `xml` column.

    .EXAMPLE
    Add-Table 'WebConfigs' { Xml 'WebConfig' -XmlSchemaCollection 'webconfigschema'' -Document }

    Demonstrates how to create an `xml` column that holds an entire XML document.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # Name of an XML schema collection
        $XmlSchemaCollection,

        [Parameter()]
        [Switch]
        # Specifies that this is a well-formed XML document instead of an XML fragment.
        $Document,

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