function New-Column
{
    <#
    .SYNOPSIS
    Creates a column object which can be used with the `Add-Table` or `Add-Column` migrations.

    .DESCRIPTION
    Returns an object that can be used when adding columns or creating tables to get the SQL needed to create that column.  The returned object has the following members:

     * Name - the name of the column
     * Definition - the simplified column definition, with no default constraint
     * DefaultExpression - the expression for the default constraint, if any
     * RowGuidCol - a boolean flag indicating if the column is a ROWGUIDCOL
     * GetColumnDefinition(string schemaName, string tableName) - Gets the full, complete table definition SQL used to create the column

    .EXAMPLE
    New-Column -Name IsFunctioning -Bit -NotNull -Default 1 

    Creates an object for gettng the to create an IsFunctioning column, e.g. `[IsFunctioning] bit not null constraint DF_<TableName>_<ColumnName> default 1`.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the column.
        $Name,

        [Parameter(Mandatory=$true,ParameterSetName='AsVarChar')]
        [Switch]
        # Creates a varchar column.
        $VarChar,

        [Parameter(Mandatory=$true,ParameterSetName='AsChar')]
        [Switch]
        # Creates a char column.
        $Char,

        [Parameter(Mandatory=$true,ParameterSetName='AsBinary')]
        [Switch]
        # Creates a binary column.
        $Binary,

        [Parameter(Mandatory=$true,ParameterSetName='AsVarBinary')]
        [Switch]
        # Creates a varbinary column.
        $VarBinary,

        [Parameter(Position=2,ParameterSetName='AsVarChar')]
        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsChar')]
        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsBinary')]
        [Parameter(Position=2,ParameterSetName='AsVarBinary')]
        [int64]
        # The size/length of the column.  Default is `max`.
        $Size,

        [Parameter(ParameterSetName='AsVarChar')]
        [Parameter(ParameterSetName='AsChar')]
        [Switch]
        # Creates a char/varchar column to hold unicode values.
        $Unicode,

        [Parameter(ParameterSetName='AsVarBinary')]
        [Switch]
        # Stores the varbinary(max) data in a filestream data container on the file system.  Only valid for varbinary(max) columns.
        $FileStream,

        [Parameter(ParameterSetName='AsVarChar')]
        [Parameter(ParameterSetName='AsChar')]
        [string]
        # The collation to use for storing text.
        $Collation,

        [Parameter(Mandatory=$true,ParameterSetName='AsBigInt')]
        [Parameter(Mandatory=$true,ParameterSetName='AsBigIntIdentity')]
        [Switch]
        # Creates a bigint column.
        $BigInt,

        [Parameter(Mandatory=$true,ParameterSetName='AsInt')]
        [Parameter(Mandatory=$true,ParameterSetName='AsIntIdentity')]
        [Switch]
        # Creates an int column.
        $Int,

        [Parameter(Mandatory=$true,ParameterSetName='AsSmallint')]
        [Parameter(Mandatory=$true,ParameterSetName='AsSmallIntIdentity')]
        [Switch]
        # Creates an smallint column.
        $SmallInt,

        [Parameter(Mandatory=$true,ParameterSetName='AsTinyint')]
        [Parameter(Mandatory=$true,ParameterSetName='AsTinyIntIdentity')]
        [Switch]
        # Creates an tinyint column.
        $TinyInt,

        [Parameter(Mandatory=$true,ParameterSetName='AsNumeric')]
        [Parameter(Mandatory=$true,ParameterSetName='AsNumericIdentity')]
        [Switch]
        # Creates a numeric column.
        $Numeric,

        [Parameter(Mandatory=$true,ParameterSetName='AsDecimal')]
        [Parameter(Mandatory=$true,ParameterSetName='AsDecimalIdentity')]
        [Switch]
        # Creates a numeric column.
        $Decimal,

        [Parameter(Mandatory=$true,ParameterSetName='AsFloat')]
        [Switch]
        # Creates a float column.
        $Float,

        [Parameter(Mandatory=$true,ParameterSetName='AsReal')]
        [Switch]
        # Creates a real column.
        $Real,

        [Parameter(Mandatory=$true,ParameterSetName='AsDate')]
        [Switch]
        # Creates a date column.
        $Date,

        [Parameter(Mandatory=$true,ParameterSetName='AsDateTime2')]
        [Switch]
        # Creates a datetime2 column.
        $Datetime2,

        [Parameter(Mandatory=$true,ParameterSetName='AsDateTimeOffset')]
        [Switch]
        # Creates a datetimeoffset column.
        $DateTimeOffset,

        [Parameter(Mandatory=$true,ParameterSetName='AsTime')]
        [Switch]
        # Creates a date column.
        $Time,

        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsNumeric')]
        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsNumericIdentity')]
        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsDecimal')]
        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsDecimalIdentity')]
        [Parameter(Position=2,ParameterSetName='AsFloat')]
        [Parameter(Position=2,ParameterSetName='AsDateTime2')]
        [Parameter(Position=2,ParameterSetName='AsDateTimeOffset')]
        [int]
        $Precision,

        [Parameter(Position=3,ParameterSetName='AsNumeric')]
        [Parameter(Position=3,ParameterSetName='AsDecimal')]
        [Parameter(Position=3,ParameterSetName='AsDateTimeOffset')]
        [int]
        $Scale,

        [Parameter(Mandatory=$true,ParameterSetName='AsTinyIntIdentity')]
        [Parameter(Mandatory=$true,ParameterSetName='AsSmallIntIdentity')]
        [Parameter(Mandatory=$true,ParameterSetName='AsIntIdentity')]
        [Parameter(Mandatory=$true,ParameterSetName='AsBigIntIdentity')]
        [Parameter(Mandatory=$true,ParameterSetName='AsDecimalIdentity')]
        [Parameter(Mandatory=$true,ParameterSetName='AsNumericIdentity')]
        [Switch]
        # Make this row an identity, with an auto-incrementing primary key.
        $Identity,

        [Parameter(Position=2,ParameterSetName='AsTinyIntIdentity')]
        [Parameter(Position=2,ParameterSetName='AsSmallIntIdentity')]
        [Parameter(Position=2,ParameterSetName='AsIntIdentity')]
        [Parameter(Position=2,ParameterSetName='AsBigIntIdentity')]
        [Parameter(Position=4,ParameterSetName='AsDecimalIdentity')]
        [Parameter(Position=4,ParameterSetName='AsNumericIdentity')]
        [int]
        $Seed = 1,

        [Parameter(Position=3,ParameterSetName='AsTinyIntIdentity')]
        [Parameter(Position=3,ParameterSetName='AsSmallIntIdentity')]
        [Parameter(Position=3,ParameterSetName='AsIntIdentity')]
        [Parameter(Position=3,ParameterSetName='AsBigIntIdentity')]
        [Parameter(Position=5,ParameterSetName='AsDecimalIdentity')]
        [Parameter(Position=5,ParameterSetName='AsNumericIdentity')]
        [int]
        $Increment = 1,

        [Parameter(ParameterSetName='AsTinyIntIdentity')]
        [Parameter(ParameterSetName='AsSmallIntIdentity')]
        [Parameter(ParameterSetName='AsIntIdentity')]
        [Parameter(ParameterSetName='AsBigIntIdentity')]
        [Parameter(ParameterSetName='AsDecimalIdentity')]
        [Parameter(ParameterSetName='AsNumericIdentity')]
        [Switch]
        $NotForReplication,

        [Parameter(Mandatory=$true,ParameterSetName='AsMoney')]
        [Switch]
        # Creates a money column.
        $Money,

        [Parameter(Mandatory=$true,ParameterSetName='AsSmallmoney')]
        [Switch]
        # Creates an smallmoney column.
        $SmallMoney,

        [Parameter(Mandatory=$true,ParameterSetName='AsBit')]
        [Switch]
        # Creates a bit column.
        $Bit,

        [Parameter(Mandatory=$true,ParameterSetName='AsUniqueIdentifier')]
        [Switch]
        # Creates a date column.
        $UniqueIdentifier,

        [Parameter(ParameterSetName='AsUniqueIdentifier')]
        [Switch]
        # Creates a date column.
        $RowGuidCol,

        [Parameter(Mandatory=$true,ParameterSetName='AsXml')]
        [Switch]
        # Creates an XML column for holding XML *content*.  Use the `Document` switch to store XML documents.
        $Xml,

        [Parameter(ParameterSetName='AsXml')]
        [Switch]
        # Creates a column to store XML documents.  You must also specify the XmlSchemaCollection.
        $Document,

        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsXml')]
        [string]
        # The XML schema collection for the XML column.  Required when storing an XML document.
        $XmlSchemaCollection,

        [Parameter(Mandatory=$true,ParameterSetName='AsSqlVariant')]
        [Switch]
        # Creates a sqlvariant column.
        $SqlVariant,

        [Parameter(Mandatory=$true,ParameterSetName='AsRowVersion')]
        [Switch]
        [Alias('TimeStamp')]
        # Creates a rowversion/timestamp column.
        $RowVersion,

        [Parameter(Mandatory=$true,ParameterSetName='AsHierarchyID')]
        [Switch]
        # Creates a hierarchyid column.
        $HierarchyID,

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ExplicitDataType')]
        [string]
        # The datatype of the new column.
        $DataType,

        [Parameter(ParameterSetName='AsVarChar')]
        [Parameter(ParameterSetName='AsChar')]
        [Parameter(ParameterSetName='AsBinary')]
        [Parameter(ParameterSetName='AsVarBinary')]
        [Parameter(ParameterSetName='AsBigInt')]
        [Parameter(ParameterSetName='AsInt')]
        [Parameter(ParameterSetName='AsSmallint')]
        [Parameter(ParameterSetName='AsTinyint')]
        [Parameter(ParameterSetName='AsNumeric')]
        [Parameter(ParameterSetName='AsDecimal')]
        [Parameter(ParameterSetName='AsBit')]
        [Parameter(ParameterSetName='AsMoney')]
        [Parameter(ParameterSetName='AsSmallmoney')]
        [Parameter(ParameterSetName='AsFloat')]
        [Parameter(ParameterSetName='AsReal')]
        [Parameter(ParameterSetName='AsDate')]
        [Parameter(ParameterSetName='AsDateTime2')]
        [Parameter(ParameterSetName='AsDateTimeOffset')]
        [Parameter(ParameterSetName='AsTime')]
        [Parameter(ParameterSetName='AsUniqueIdentifier')]
        [Parameter(ParameterSetName='AsXml')]
        [Parameter(ParameterSetName='AsSqlVariant')]
        [Parameter(ParameterSetName='AsRowVersion')]
        [Parameter(ParameterSetName='AsHierarchyID')]
        [Parameter(ParameterSetName='ExplicitDataType')]
        [Switch]
        # Optimizes the column storage for null values. Cannot be used with the `NotNull` switch.
        $Sparse,

        [Parameter(ParameterSetName='AsVarChar')]
        [Parameter(ParameterSetName='AsChar')]
        [Parameter(ParameterSetName='AsBinary')]
        [Parameter(ParameterSetName='AsVarBinary')]
        [Parameter(ParameterSetName='AsBigInt')]
        [Parameter(ParameterSetName='AsInt')]
        [Parameter(ParameterSetName='AsSmallint')]
        [Parameter(ParameterSetName='AsTinyint')]
        [Parameter(ParameterSetName='AsNumeric')]
        [Parameter(ParameterSetName='AsDecimal')]
        [Parameter(ParameterSetName='AsBit')]
        [Parameter(ParameterSetName='AsMoney')]
        [Parameter(ParameterSetName='AsSmallmoney')]
        [Parameter(ParameterSetName='AsFloat')]
        [Parameter(ParameterSetName='AsReal')]
        [Parameter(ParameterSetName='AsDate')]
        [Parameter(ParameterSetName='AsDateTime2')]
        [Parameter(ParameterSetName='AsDateTimeOffset')]
        [Parameter(ParameterSetName='AsTime')]
        [Parameter(ParameterSetName='AsUniqueIdentifier')]
        [Parameter(ParameterSetName='AsXml')]
        [Parameter(ParameterSetName='AsSqlVariant')]
        [Parameter(ParameterSetName='AsRowVersion')]
        [Parameter(ParameterSetName='AsHierarchyID')]
        [Parameter(ParameterSetName='ExplicitDataType')]
        [Switch]
        # Makes the column not nullable.  Canno be used with the `Sparse` switch.
        $NotNull,

        [Object]
        # A SQL Server expression for the column's default value.
        $Default,

        [string]
        # A description of the column.
        $Description        
    )

    if( $PSBoundParameters.ContainsKey('NotNull') -and $PSBoundParameters.ContainsKey('Sparse') )
    {
        throw ('Column {0}: A column cannot be NOT NULL and SPARSE.  Please choose one switch: `NotNull` or `Sparse`, but not both.' -f $Name)
        return
    }

    $nullable = 'Null'
    if( $NotNull )
    {
        $nullable = 'NotNull'
    }
    elseif( $Sparse )
    {
        $nullable = 'Sparse'
    }

    $columnIdentity = $null
    if( $PSCmdlet.ParameterSetName -like 'As*Identity' )
    {
        if( $PSBoundParameters.ContainsKey('Seed') )
        {
            $columnIdentity = New-Object Rivet.Identity $Seed,$Increment,$NotForReplication.IsPresent
        }
        else
        {
            $columnIdentity = New-Object Rivet.Identity $NotForReplication.IsPresent
        }
    }

    $dataSize = $null
    if( $PSBoundParameters.ContainsKey('Size') )
    {
        $dataSize = New-Object Rivet.CharacterLength $Size
    }
    elseif( $PSBoundParameters.ContainsKey('Precision') -and $PSBoundParameters.ContainsKey('Scale') )
    {
        $dataSize = New-Object Rivet.PrecisionScale $Precision,$Scale
    }
    elseif( $PSBoundParameters.ContainsKey('Precision')  )
    {
        $dataSize = New-Object Rivet.PrecisionScale $Precision
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        'AsBigInt'
        {
           [Rivet.Column]::BigInt( $Name, $nullable, $Default, $Description ) 
           break
        }
        'AsBigIntIdentity'
        {
            [Rivet.Column]::BigInt( $Name, $columnIdentity, $Description )
            break
        }
        'AsBinary'
        {
            [Rivet.Column]::Binary( $Name, $dataSize, $nullable, $Default, $Description )
            break
        }
        'AsBit'
        {
            [Rivet.Column]::Bit( $Name, $nullable, $Default, $Description )
            break
        }
        'AsChar'
        {
            if( $Unicode )
            {
                [Rivet.Column]::NChar( $Name, $dataSize, $Collation, $nullable, $Default, $Description )
            }
            else
            {
                [Rivet.Column]::Char( $Name, $dataSize, $Collation, $nullable, $Default, $Description )
            }
            break
        }
        'AsDate'
        {
            [Rivet.Column]::Date( $Name, $nullable, $Default, $Description )
            break
        }
        'AsDateTime2'
        {
            [Rivet.Column]::DateTime2( $Name, $dataSize, $nullable, $Default, $Description )
            break
        }
        'AsDateTimeOffset'
        {
            [Rivet.Column]::DateTimeOffset( $Name, $dataSize, $nullable, $Default, $Description )
            break
        }
        'AsDecimal'
        {
           [Rivet.Column]::Decimal( $Name, $dataSize, $nullable, $Default, $Description ) 
           break
        }
        'AsDecimalIdentity'
        {
            [Rivet.Column]::Decimal( $Name, $dataSize, $columnIdentity, $Description )
            break
        }
        'AsFloat'
        {
            [Rivet.Column]::Float( $Name, $dataSize, $nullable, $Default, $Description )
            break
        }
        'AsHierarchyID'
        {
            [Rivet.Column]::HierarchyID( $Name, $nullable, $Default, $Description )
        }
        'AsInt'
        {
           [Rivet.Column]::Int( $Name, $nullable, $Default, $Description ) 
           break
        }
        'AsIntIdentity'
        {
            [Rivet.Column]::Int( $Name, $columnIdentity, $Description )
            break
        }
        'AsMoney'
        {
            [Rivet.Column]::Money( $Name, $nullable, $Default, $Description )
            break
        }
        'AsNumeric'
        {
           [Rivet.Column]::Numeric( $Name, $dataSize, $nullable, $Default, $Description ) 
           break
        }
        'AsNumericIdentity'
        {
            [Rivet.Column]::Numeric( $Name, $dataSize, $columnIdentity, $Description )
            break
        }
        'AsReal'
        {
            [Rivet.Column]::Real( $Name, $nullable, $Default, $Description )
            break
        }
        'AsRowVersion'
        {
            [Rivet.Column]::RowVersion( $Name, $nullable, $Default, $Description )
            break
        }
        'AsSmallInt'
        {
           [Rivet.Column]::SmallInt( $Name, $nullable, $Default, $Description ) 
           break
        }
        'AsSmallIntIdentity'
        {
            [Rivet.Column]::SmallInt( $Name, $columnIdentity, $Description )
            break
        }
        'AsSmallMoney'
        {
            [Rivet.Column]::SmallMoney( $Name, $nullable, $Default, $Description )
            break
        }
        'AsSqlVariant'
        {
            [Rivet.Column]::SqlVariant( $Name, $nullable, $Default, $Description )
            break
        }
        'AsTime'
        {
            [Rivet.Column]::Time( $Name, $dataSize, $nullable, $Default, $Description )
            break
        }
        'AsTinyInt'
        {
           [Rivet.Column]::TinyInt( $Name, $nullable, $Default, $Description ) 
           break
        }
        'AsTinyIntIdentity'
        {
            [Rivet.Column]::TinyInt( $Name, $columnIdentity, $Description )
            break
        }
        'AsUniqueIdentifier'
        {
            [Rivet.Column]::UniqueIdentifier( $Name, $RowGuidCol, $nullable, $Default, $Description )
            break
        }
        'AsVarBinary'
        {
            [Rivet.Column]::VarBinary( $Name, $dataSize, $FileStream, $nullable, $Default, $Description )
            break
        }
        'AsVarChar'
        {
            if( $Unicode )
            {
                [Rivet.Column]::NVarChar( $Name, $dataSize, $Collation, $nullable, $Default, $Description )
            }
            else
            {
                [Rivet.Column]::VarChar( $Name, $dataSize, $Collation, $nullable, $Default, $Description )
            }
            break
        }
        'AsXml'
        {
            [Rivet.Column]::Xml( $Name, $Document, $XmlSchemaCollection, $nullable, $Default, $Description )
            break
        }
        'ExplicitDataType'
        {
            New-Object Rivet.Column $Name,$DataType,$nullable,$Default,$Description
            break
        }
        default
        {
            $params = $PSBoundParameters.Keys | ForEach-Object { '{0}: {1}' -f $_,$PSBoundParameters.$_ }
            $params = $params -join '; '
            throw ('Unknown parameter set ''{0}'': @{{ {1} }}' -f $PSCmdlet.ParameterSetName,$params)
        }
    }
        
    return

    if( $PSCmdlet.ParameterSetName -eq 'ExplicitDataType' )
    {
        $columnDefinition = '[{0}] {1}' -f $Name, $DataType
    }
    else
    {
        if( $PSCmdlet.ParameterSetName -notmatch '^As(.*?)(Identity)?$' )
        {
            throw ('Unknown parameter set {0}.' -f $PSCmdlet.ParameterSetName)
        }

        $DataType = $matches[1].ToLower()
        if( $PSBoundParameters.ContainsKey('Unicode') )
        {
            $DataType = 'n{0}' -f $DataType
        }

        $typeSize = ''
        if( $PSCmdlet.ParameterSetName -match 'As(Var)?(Binary|Char)' )
        {
            $typeSize = '(max)'
        }
    
        if( $PSBoundParameters.ContainsKey('Size') )
        {
            $typeSize = '({0})' -f $Size
        }
        elseif( $PSBoundParameters.ContainsKey('Precision') )
        {
            if( $PSBoundParameters.ContainsKey('Scale') )
            {
                $typeSize = '({0},{1})' -f $Precision,$Scale
            }
            else
            {
                $typeSize = '({0})' -f $Precision
            }
        }
        elseif( $PSBoundParameters.ContainsKey('Document') )
        {
            if( -not $XmlSchemaCollection )
            {
                throw ('Column {0}: Document-based XML columns must have an XML schema specified so that SQL Server can validate that you are inserting valid XML documents. Set the name of the XML schema collection with the XmlSchemaCollection parameter.' -f $Name)
                return
            }
            $typeSize = '(document {0})' -f $XmlSchemaCollection
        }
        $columnDefinition = '[{0}] {1}{2}' -f $Name,$DataType,$typeSize
    }

    if( $PSBoundParameters.ContainsKey('FileStream') )
    {
        $columnDefinition = '{0} filestream' -f $columnDefinition
    }

    if( $PSBoundParameters.ContainsKey('Collation') )
    {
        $columnDefinition = '{0} collate {1}' -f $columnDefinition,$Collation
    }

    if( $PSBoundParameters.ContainsKey('Sparse') )
    {
        $columnDefinition = '{0} sparse' -f $columnDefinition
    }

    if( $PSCmdlet.ParameterSetName -like '*Identity' )
    {
        $columnDefinition = '{0} identity ({1},{2})' -f $columnDefinition,$Seed,$Increment
        if( $PSBoundParameters.ContainsKey('NotForReplication') )
        {
            $columnDefinition = '{0} not for replication' -f $columnDefinition
        }
    }
    elseif( $PSBoundParameters.ContainsKey('NotNull') )
    {
        $columnDefinition = '{0} not null' -f $columnDefinition
    }

    $columnInfo = @{ 
                        Name = $Name;
                        Definition = $columnDefinition;
                        Description = $Description;
                        DefaultExpression = $Default;
                        RowGuidCol = $PSBoundParameters.ContainsKey('RowGuidCol');
                   }

    $getColumnDefinitionMethod = {
        param(
            [Parameter(Mandatory=$true)]
            [string]
            # The name of the table where the column is getting added.
            $TableName,

            [string]
            # The name of the table's schema. Default is `dbo`.
            $SchemaName = 'dbo'
        )

        $dfConstraintClause = ''
        if( $this.DefaultExpression )
        {
            $dfConstraintName = New-DefaultConstraintName -SchemaName $SchemaName -TableName $TableName -ColumnName $this.Name 
            $dfConstraintClause = 'constraint {0} default {1}' -f $dfConstraintName,$this.DefaultExpression
        }

        $rowGuidColClause = ''
        if( $this.RowGuidCol )
        {
            $rowGuidColClause = 'rowguidcol'
        }

        return '{0} {1} {2}' -f $this.Definition,$dfConstraintClause,$rowGuidColClause

    }

    New-Object PsObject -Property $columnInfo | 
        Add-Member -MemberType ScriptMethod -Name 'GetColumnDefinition' -Value $getColumnDefinitionMethod -PassThru

}