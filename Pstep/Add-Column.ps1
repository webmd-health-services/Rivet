function Add-Column
{
    <#
    .SYNOPSIS
    Adds a column to a table.

    .DESCRIPTION
    The column must not exist, otherwise the migration will fail.

    You can set the default value of a column.  Pstep will create a default constraint named `DF_<TableSchema>_<TableName>_<ColumnName>`.

    .EXAMPLE
    Add-Column -Name IsFunctioning -Bit -NotNull -Default 1 -TableName IronManSuits 

    Adds the `IsFunctioning` column to the IronManSuites as a bit datatype, with a default value of 1.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the column to add.
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
        [Parameter(Position=2,ParameterSetName='AsChar')]
        [Parameter(Position=2,ParameterSetName='AsBinary')]
        [Parameter(Position=2,ParameterSetName='AsVarBinary')]
        [int64]
        # The size/length of the column.  Default is `max`.
        $Size,

        [Parameter(ParameterSetName='AsVarChar')]
        [Parameter(ParameterSetName='AsChar')]
        [Switch]
        # Creates a char/varchar column to hold unicode values.
        $Unicode,

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

        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsNumeric')]
        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsNumericIdentity')]
        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsDecimal')]
        [Parameter(Mandatory=$true,Position=2,ParameterSetName='AsDecimalIdentity')]
        [Parameter(Position=2,ParameterSetName='AsFloat')]
        [int]
        $Precision,

        [Parameter(Position=3,ParameterSetName='AsNumeric')]
        [Parameter(Position=3,ParameterSetName='AsDecimal')]
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

        [Parameter(Mandatory=$true,ParameterSetName='AsReal')]
        [Switch]
        # Creates a real column.
        $Real,

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

        [Parameter(Mandatory=$true,ParameterSetName='AsDate')]
        [Switch]
        # Creates a date column.
        $Date,

        [Parameter(Mandatory=$true,ParameterSetName='AsDatetime')]
        [Switch]
        # Creates a datetime column.
        $DateTime,

        [Parameter(Mandatory=$true,ParameterSetName='AsDatetime2')]
        [Switch]
        # Creates a datetime2 column.
        $Datetime2,

        [Parameter(Mandatory=$true,ParameterSetName='AsDatetimeoffset')]
        [Switch]
        # Creates a datetimeoffset column.
        $DateTimeOffset,

        [Parameter(Mandatory=$true,ParameterSetName='AsSmalldatetime')]
        [Switch]
        # Creates a date column.
        $SmallDateTime,

        [Parameter(Mandatory=$true,ParameterSetName='AsTime')]
        [Switch]
        # Creates a date column.
        $Time,

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
        # Creates a column to store XML documents.
        $Document,

        [Parameter(ParameterSetName='AsXml')]
        [string]
        # The XML schema collection for the XML column.
        $XmlSchemaCollection,

        [Parameter(Mandatory=$true,ParameterSetName='AsSql_Variant')]
        [Switch]
        # Creates a sqlvariant column.
        $SqlVariant,

        [Parameter(Mandatory=$true,ParameterSetName='AsTimestamp')]
        [Switch]
        [Alias('TimeStamp')]
        # Creates a rowversion/timestamp column.
        $RowVersion,

        [Parameter(Mandatory=$true,ParameterSetName='AsHierarchyID')]
        [Switch]
        # Creates a hierarchyid column.
        $HierarchyID,

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
        [Parameter(ParameterSetName='AsDatetime')]
        [Parameter(ParameterSetName='AsDatetime2')]
        [Parameter(ParameterSetName='AsDatetimeoffset')]
        [Parameter(ParameterSetName='AsSmalldatetime')]
        [Parameter(ParameterSetName='AsTime')]
        [Parameter(ParameterSetName='AsXml')]
        [Parameter(ParameterSetName='AsSqlVariant')]
        [Parameter(ParameterSetName='AsRowVersion')]
        [Parameter(ParameterSetName='AsHierarchyID')]
        [Switch]
        # Makes the column not nullable.
        $NotNull,

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
        [Parameter(ParameterSetName='AsDatetime')]
        [Parameter(ParameterSetName='AsDatetime2')]
        [Parameter(ParameterSetName='AsDatetimeoffset')]
        [Parameter(ParameterSetName='AsSmalldatetime')]
        [Parameter(ParameterSetName='AsTime')]
        [Parameter(ParameterSetName='AsXml')]
        [Parameter(ParameterSetName='AsSqlVariant')]
        [Parameter(ParameterSetName='AsRowVersion')]
        [Parameter(ParameterSetName='AsHierarchyID')]
        [string]
        # The default column value.
        $Default,

        [string]
        # A description of the column.
        $Description,
        
        # The name of the table where the column should be added.
        [Parameter(Mandatory=$true)]
        [string]
        $TableName,

        [string]
        # The schema of the table where the column should be added.  Default is `dbo`.
        $TableSchema = 'dbo'
    )

    if( $PSCmdlet.ParameterSetName -notmatch '^As(.*?)(Identity)?$' )
    {
        throw ('Unknown parameter set {0}.' -f $PSCmdlet.ParameterSetName)
    }

    $datatype = $matches[1].ToLower()
    if( $PSBoundParameters.ContainsKey('Unicode') )
    {
        $datatype = 'n{0}' -f $datatype
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

    $columnDescription = '[{0}] {1}{2}' -f $Name,$datatype,$typeSize
    Write-Host ('                   {0}.{1} + {2}' -f $TableSchema,$TableName,$columnDescription)

    $query = @'
    alter table [{0}].[{1}] add {2}
'@ -f $TableSchema,$TableName,$columnDescription
    Invoke-Query -Query $query
}