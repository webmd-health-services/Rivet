
function Add-Table
{
    <#
    .SYNOPSIS
    Creates a new table in the database.

    .DESCRIPTION
    The column's for the table should be created and returned in a script block, which is passed as the value of the `Column` parameter.  For example,

        Add-Table 'Suits' {
            Int 'id' -Identity
            TinyInt 'pieces -NotNull
            VarChar 'color' -NotNull
        }

    .LINK
    bigint

    .LINK
    binary

    .LINK
    bit

    .LINK
    char

    .LINK
    date

    .LINK
    datetime

    .LINK
    datetime2

    .LINK
    datetimeoffset

    .LINK
    decimal

    .LINK
    float

    .LINK
    hierarchyid

    .LINK
    int

    .LINK
    money

    .LINK
    nchar

    .LINK
    numeric

    .LINK
    nvarchar

    .LINK
    real

    .LINK
    rowversion

    .LINK
    smalldatetime

    .LINK
    smallint

    .LINK
    smallmoney

    .LINK
    sqlvariant

    .LINK
    time

    .LINK
    tinyint

    .LINK
    uniqueidentifier

    .LINK
    varbinary

    .LINK
    varchar

    .LINK
    xml

    .EXAMPLE
    Add-Table -Name 'Ties' -Column { VarChar 'color' -NotNull }

    Creates a `Ties` table with a single column for each tie's color.  Pretty!
    #>
    [CmdletBinding(DefaultParameterSetName='AsNormalTable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table.
        $Name,

        [string]
        # The table's schema.  Defaults to 'dbo'.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='AsNormalTable')]
        [ScriptBlock]
        # A script block that returns the table's columns.
        $Column,

        [Parameter(Mandatory=$true,ParameterSetName='AsFileTable')]
        [Switch]
        # Creates a [FileTable](http://msdn.microsoft.com/en-us/library/ff929144.aspx) table.
        $FileTable,

        [string]
        # Specifies the partition scheme or filegroup on which the table is stored, e.g. `ON $FileGroup`
        $FileGroup,

        [string]
        # The filegroup where text, ntext, image, xml, varchar(max), nvarchar(max), and varbinary(max) columns are stored. The table has to have one of those columns. For example, `TEXTIMAGE_ON $TextImageFileGroup`.
        $TextImageFileGroup,

        [string]
        # Specifies the filegroup for FILESTREAM data, e.g. `FILESTREAM_ON $FileStreamFileGroup`.
        $FileStreamFileGroup,

        [string[]]
        # Specifies one or more table options.
        $Option,

        [string]
        # A description of the table.
        $Description
    )

    Set-StrictMode -Version 'Latest'

    $columns = & $Column | Set-DefaultConstraintName -SchemaName $SchemaName -TableName $Name
 
    $tableOp = New-Object 'Rivet.Operations.AddTableOperation' $SchemaName, $Name, $columns, $FileTable, $FileGroup, $TextImageFileGroup, $FileStreamFileGroup, $Option

    $addDescriptionArgs = @{
                                SchemaName = $SchemaName;
                                TableName = $Name;
                            }

    if( $Description )
    {
        $tableDescriptionOp = Add-Description -Description $Description @addDescriptionArgs
        $tableOp.ChildOperations.Add($tableDescriptionOp)
    }

    $tableOp | Write-Output
    $tableOp.ChildOperations | Write-Output

    foreach( $columnItem in $columns )
    {
        if( $columnItem.Description )
        {
            Add-Description -Description $columnItem.Description -ColumnName $columnItem.Name @addDescriptionArgs | Write-Output
        }
    }
}


