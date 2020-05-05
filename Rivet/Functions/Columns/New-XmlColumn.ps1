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
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Position=1)]
        # Name of an XML schema collection
        [String]$XmlSchemaCollection,

        # Specifies that this is a well-formed XML document instead of an XML fragment.
        [switch]$Document,

        [Parameter(Mandatory,ParameterSetName='NotNull')]
        # Don't allow `NULL` values in this column.
        [switch]$NotNull,

        [Parameter(ParameterSetName='Nullable')]
        # Store nulls as Sparse.
        [switch]$Sparse,

        # A SQL Server expression for the column's default value 
        [String]$Default,

        # The name of the default constraint for the column's default expression. Required if the Default parameter is given.
        [String]$DefaultConstraintName,
            
        # A description of the column.
        [String]$Description
    )

    $nullable = [Rivet.Nullable]::Null
    if( $PSCmdlet.ParameterSetName -eq 'NotNull' )
    {
        $nullable = [Rivet.Nullable]::NotNull
    }
    else
    {
        if( $Sparse )
        {
            $nullable = [Rivet.Nullable]::Sparse
        }
    }

    if( $XmlSchemaCollection )
    {
        [Rivet.Column]::Xml($Name, $Document, $XmlSchemaCollection, $nullable, $Default, $DefaultConstraintName, $Description)
    }
    else
    {
        [Rivet.Column]::Xml($Name, $nullable, $Default, $DefaultConstraintName, $Description)
    }
}

    
Set-Alias -Name 'Xml' -Value 'New-XmlColumn'