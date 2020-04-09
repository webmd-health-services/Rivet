function New-Column
{
    <#
    .SYNOPSIS
    Creates a column object of an explicit datatype which can be used with the `Add-Table` or `Update-Table` migrations.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Members' {
            New-Column 'Birthday' 'datetime' 
        }
    
    This column is useful for creating columns of custom types or types for which Rivet doesn't have a specific function.

    Returns an object that can be used when adding columns or creating tables to get the SQL needed to create that column. 
    
    .LINK
    New-BigIntColumn

    .LINK
    New-BinaryColumn

    .LINK
    New-BitColumn

    .LINK
    New-CharColumn

    .LINK
    New-DateColumn

    .LINK
    New-DateTime2Column

    .LINK
    New-DateTimeOffsetColumn

    .LINK
    New-DecimalColumn

    .LINK
    New-FloatColumn

    .LINK
    New-HierarchyIDColumn

    .LINK
    New-IntColumn

    .LINK
    New-MoneyColumn

    .LINK
    New-NCharColumn

    .LINK
    New-NVarCharColumn

    .LINK
    New-RealColumn

    .LINK
    New-RowVersionColumn

    .LINK
    New-SmallDateTimeColumn

    .LINK
    New-SmallIntColumn

    .LINK
    New-SmallMoneyColumn

    .LINK
    New-SqlVariantColumn

    .LINK
    New-TimeColumn

    .LINK
    New-TinyIntColumn

    .LINK
    New-UniqueIdentifierColumn

    .LINK
    New-VarBinaryColumn

    .LINK
    New-VarCharColumn

    .LINK
    New-XmlColumn

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'datetime' -NotNull }

    Demonstrates how to create a required `datetime` column.

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'float(7)' -NotNull }

    Demonstrates that the value of the `DataType` parameter should also include any precision/scale/size specifiers.

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'datetime' -Sparse }

    Demonstrate show to create a nullable, sparse `datetime` column when adding a new table.

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'datetime' -NotNull -Default 'getdate()' }
    
    Demonstrates how to create a date column with a default value, in this case the current date.  (You alwyas use UTC dates, right?)  Probably not a great example, setting someone's birthday to the current date. Reasons are left as an exercise for the reader.

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'datetime' -Description 'The members birthday.' }

    Demonstrates how to create an optional date column with a description.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(

        [Parameter(Mandatory,Position=0)]
        # The Name of the new column.
        [String]$Name,

        [Parameter(Mandatory,Position=1)]
        # The datatype of the new column. Scale/size/precision clause is optional. 
        [String]$DataType,

        [Parameter(ParameterSetName='Nullable')]
        [Parameter(ParameterSetName='NotNull')]
        # Allow the column to be its maximum size. Sets the columnn's size clause to `(max)`. Only use this with columns whose underlying type supports it. If you supply this argument, the `Size`, `Precision`, and `Scale` parameters are ignored.
        [switch]$Max,

        [Parameter(ParameterSetName='Nullable')]
        [Parameter(ParameterSetName='NotNull')]
        # The size/length of the column. Sets the column's size clause to `($Size)`. Ignored if `Max` parameter is used. If provided, the `Precision` and `Scale` parameters are ignored.
        [int]$Size,

        [Parameter(ParameterSetName='Nullable')]
        [Parameter(ParameterSetName='NotNull')]
        # The precision of the column. Set's the columns size clause to `($Precision)`. If `Scale` is also given, the size clause is set to `($Precision,$Scale)`. Ignored if the `Max` or `Size` parameters are used.
        [int]$Precision,

        [Parameter(ParameterSetName='Nullable')]
        [Parameter(ParameterSetName='NotNull')]
        # The scale of the column. Set's the column's size clause to `($Scale)`. If `Precision` is also given, the size clause is set to `($Precision,$Scale)`. Ignored if the `Max` or `Size` parameters are used.
        [int]$Scale,

        [Parameter(Mandatory,ParameterSetName='Identity')]
        # Make the column an identity.
        [switch]$Identity,

        [Parameter(ParameterSetName='Identity')]
        # The starting value for the identity column.
        [int]$Seed,

        [Parameter(ParameterSetName='Identity')]
        # The increment between new identity values. 
        [int]$Increment,

        [Parameter(ParameterSetName='Identity')]
        # Don't replicate the identity column value.
        [switch]$NotForReplication,

        [Parameter(ParameterSetName='Nullable')]
        # Optimizes the column storage for null values. Cannot be used with the `NotNull` switch.
        [switch]$Sparse,

        [Parameter(ParameterSetName='NotNull')]
        # Makes the column not nullable.  Cannot be used with the `Sparse` switch.
        [switch]$NotNull,

        [Parameter(ParameterSetName='Nullable')]
        [Parameter(ParameterSetName='NotNull')]
        # The collation of the column.
        [String]$Collation,

        # Whether or not to make the column a `rowguidcol`.
        [switch]$RowGuidCol,

        [Parameter(ParameterSetName='Nullable')]
        [Parameter(ParameterSetName='NotNull')]
        # A SQL Server expression for the column's default value.
        [Object]$Default,

        [Parameter(ParameterSetName='Nullable')]
        [Parameter(ParameterSetName='NotNull')]
        # The name of the default constraint for the column's default expression. Required if the Default parameter is given.
        [String]$DefaultConstraintName,

        # A description of the column.
        [String]$Description,
        
        # Whether or not the column is a filestream.
        [switch]$FileStream       
    )

    [Rivet.ColumnSize]$sizeParam = $null
    if( $Max )
    {
        $sizeParam = [Rivet.CharacterLength]::new()
    }
    elseif( $PSBoundParameters.ContainsKey('Size') )
    {
        $sizeParam = [Rivet.CharacterLength]::new($Size)
    }
    elseif( $PSBoundParameters.ContainsKey('Precision') -and $PSBoundParameters.ContainsKey('Scale') )
    {
        $sizeParam = [Rivet.PrecisionScale]::new($Precision,$Scale)
    }
    elseif( $PSBoundParameters.ContainsKey('Precision') )
    {
        $sizeParam = [Rivet.PrecisionScale]::new($Precision)
    }
    elseif( $PSBoundParameters.ContainsKey('Scale') )
    {
        $sizeParam = [Rivet.Scale]::new($Scale)
    }

    if( $PSCmdlet.ParameterSetName -eq 'Identity' )
    {
        [Rivet.Identity]$identityParam = [Rivet.Identity]::new($NotForReplication)
        if( $Seed -or $Increment )
        {
            $identityParam = [Rivet.Identity]::new($Seed, $Increment, $NotForReplication)
        }
        [Rivet.Column]::new($Name, $DataType, $sizeParam, $identityParam, $RowGuidCol, $Description, $FileStream)
    }
    else
    {
        $nullable = 'Null'
        if( $PSCmdlet.ParameterSetName -eq 'NotNull' )
        {
            $nullable = 'NotNull'
        }
        elseif( $Sparse )
        {
            $nullable = 'Sparse'
        }

        [Rivet.Column]::new($Name, $DataType, $sizeParam, $nullable, $Collation, $RowGuidCol, $Default, $DefaultConstraintName, $Description, $FileStream)
    }
}