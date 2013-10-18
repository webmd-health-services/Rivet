function Update-Column
{
    <#
    .SYNOPSIS
    Updates the datatype of a column to another datatype

    .DESCRIPTION
    It is up to the developer to make sure that the datatype conversion is valid and that no data will be lost.  

    .EXAMPLE
    Update-Column -Name "Birthday" -
    
    #>
    [CmdletBinding()]
    param(
        # The name of the table where the column should be added.
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        $TableName,

        [Alias('TableSchema')]
        [string]
        # The schema of the table where the column should be added.  Default is `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=2)]
        [string]
        # The name of the column to update.
        $Name,

        [Parameter(Mandatory=$true,ParameterSetName='AsVarChar')]
        [Switch]
        # Creates a varchar column.
        $VarChar,

        [Parameter(Mandatory=$true,ParameterSetName='AsNVarChar')]
        [Switch]
        # Creates a varchar column.
        $NVarChar,

        [Parameter(Mandatory=$true,ParameterSetName='AsChar')]
        [Switch]
        # Creates a char column.
        $Char,

        [Parameter(Mandatory=$true,ParameterSetName='AsNChar')]
        [Switch]
        # Creates a char column.
        $NChar,

        [Parameter(Mandatory=$true,ParameterSetName='AsBinary')]
        [Switch]
        # Creates a binary column.
        $Binary,

        [Parameter(Mandatory=$true,ParameterSetName='AsVarBinary')]
        [Switch]
        # Creates a varbinary column.
        $VarBinary,

        [Parameter(Position=3,ParameterSetName='AsVarChar')]
        [Parameter(Position=3,ParameterSetName='AsNVarChar')]
        [Parameter(Mandatory=$true,Position=3,ParameterSetName='AsChar')]
        [Parameter(Mandatory=$true,Position=3,ParameterSetName='AsNChar')]
        [Parameter(Mandatory=$true,Position=3,ParameterSetName='AsBinary')]
        [Parameter(Position=3,ParameterSetName='AsVarBinary')]
        [int64]
        # The size/length of the column.  Default is `max`.
        $Size,

        [Parameter(ParameterSetName='AsVarChar')]
        [Parameter(ParameterSetName='AsNVarChar')]
        [Parameter(ParameterSetName='AsVarBinary')]
        [Switch]
        # The size/length of the column.  Default is `max`.
        $Max,

        [Parameter(ParameterSetName='AsVarChar')]
        [Parameter(ParameterSetName='AsChar')]
        [Parameter(ParameterSetName='AsNVarChar')]
        [Parameter(ParameterSetName='AsNChar')]
        [string]
        # The collation to use for storing text.
        $Collation,

        [Parameter(ParameterSetName='AsBigInt')]
        [Switch]
        # Creates a bigint column.
        $BigInt,

        [Parameter(Mandatory=$true,ParameterSetName='AsInt')]
        [Switch]
        # Creates an int column.
        $Int,

        [Parameter(Mandatory=$true,ParameterSetName='AsSmallint')]
        [Switch]
        # Creates an smallint column.
        $SmallInt,

        [Parameter(Mandatory=$true,ParameterSetName='AsTinyint')]
        [Switch]
        # Creates an tinyint column.
        $TinyInt,

        [Parameter(Mandatory=$true,ParameterSetName='AsDecimal')]
        [Switch]
        # Creates a decimal column.
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

        [Parameter(Mandatory=$true,ParameterSetName='AsSmallDateTime')]
        [Switch]
        # Creates a datetimeoffset column.
        $SmallDateTime,

        [Parameter(Mandatory=$true,ParameterSetName='AsTime')]
        [Switch]
        # Creates a date column.
        $Time,

        [Parameter(Mandatory=$true,Position=3,ParameterSetName='AsDecimal')]
        [Parameter(Position=3,ParameterSetName='AsFloat')]
        [Parameter(Position=3,ParameterSetName='AsDateTime2')]
        [Parameter(Position=3,ParameterSetName='AsDateTimeOffset')]
        [int]
        # The data type's precision.  Only valid for Decimal, Float, DateTime2, and DateTimeOffset data tyes.
        $Precision,


        [Parameter(Position=4,ParameterSetName='AsDecimal')]
        [Parameter(Position=4,ParameterSetName='AsDateTimeOffset')]
        [int]
        # The data type's scale.  Only valid for Decimal, and DateTimeOffset data tyes.
        $Scale,

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

        [Parameter(Mandatory=$true, Position=3, ParameterSetName='AsXml')]
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

        [Switch]
        # Makes the column not nullable.  Cannot be used with the `NotNull` switch.
        $Sparse,

        [Switch]
        # Makes the column not nullable.  Cannot be used with the `Sparse` switch.
        $NotNull
    )

    $newColumnArgs = @{}
    $newColumnFunctionName = 'New-Column'
    if( $PSCmdlet.ParameterSetName -match '^As(.*)$' )
    {
        $DataType = $matches[1]
        $newColumnFunctionName = 'New-{0}Column' -f $DataType
    }
    elseif( $PSCmdlet.ParameterSetName -ne 'ExplicitDataType' )
    {
        throw ('Unknown Add-Column parameter set: {0}' -f $PSCmdlet.ParameterSetName)
    }
    
    $PSBoundParameters.Keys | 
        Where-Object { $_ -notmatch 'TableName|SchemaName|WithValues' } |
        Where-Object { $_ -notlike $DataType } |
        ForEach-Object { $newColumnArgs.$_ = $PSBoundParameters.$_ }

    $column = & $newColumnFunctionName @newColumnArgs

    $op = New-Object 'Rivet.Operations.UpdateColumnOperation' $SchemaName, $TableName, $column
    Write-Host(' {0}.{1} {2} ={3}' -f $SchemaName,$TableName, $column.Name, $column.GetColumnDefinition($TableName, $SchemaName, $false))
    Invoke-MigrationOperation -operation $op 
}