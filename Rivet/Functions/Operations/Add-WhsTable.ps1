
function Add-WhsTable
{
    <#
    .SYNOPSIS
    Creates a new replicated table in the database.

    .DESCRIPTION
    The `Add-WhsTable` operation adds a WHS-specific table to a WHS database. It functions almost exactly like Rivet's standard `Add-Table` operation, except it requires you to mark the table as replicated or not-replicated with the `Replicated` and `NotReplicated` switches. 
    
    `Add-WhsTable` will add four administrative columns to each replicated table: `CreateDate`, `LastUpdated`, `rowguid`, and `skipbit`. If you want to create your own `rowguidcol` column, use the `SkipRowGuidCol` switch to not create the `rowguid` column.

    The column's for the table should be created and returned in a script block, which is passed as the value of the `Column` parameter.  For example,

        Add-Table 'Suits' {
            Int 'id' -Identity
            TinyInt 'pieces -NotNull
            VarChar 'color' -NotNull
        }

    This function is new in Arc 1.5.

    .LINK
    Add-Table

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
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table.
        $Name,

        [string]
        # The table's schema.  Defaults to 'dbo'.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1)]
        [ScriptBlock]
        # A script block that returns the table's columns.
        $Column,

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
        $Description,

        [Parameter(Mandatory=$true,ParameterSetName='ReplicatedTable')]
        [Switch]
        # Marks the table as a replicated table. To determine if your table should be replicated or not, please speak with the Ops DBAs ASAP.
        $Replicated,

        [Parameter(ParameterSetName='ReplicatedTable')]
        [Switch]
        # Skip the rowguidcol column.
        $SkipRowGuidCol,

        [Parameter(Mandatory=$true,ParameterSetName='NonReplicatedTable')]
        [Switch]
        # Marks the table as a non-replicated table. To determine if your table should be replicated or not, please speak with the Ops DBAs ASAP.
        $NotReplicated
    )

    Set-StrictMode -Version 'Latest'

    $Replicated = ($PSCmdlet.ParameterSetName -eq 'ReplicatedTable')

    $paramsToSkip = @( 'SkipRowGuidCol', 'Replicated', 'NotReplicated' )
    $addTableParams = @{ }

    foreach( $key in $PSBoundParameters.Keys )
    {
        if( $paramsToSkip -notcontains $key )
        {
            $addTableParams[$key] = $PSBoundParameters[$key]
        }
    }
    
    $ops = Add-Table @addTableParams

    $addTableOp = $ops | Where-Object { $_ -is [Rivet.Operations.AddTableOperation] }

    $createRowGuidIndex = $false
    if( $Replicated )
    {
        Invoke-Command {
            smalldatetime 'CreateDate' -NotNull -Default 'getdate()' -Description 'Record created date'
            datetime 'LastUpdated' -NotNull -Default 'getdate()' -Description 'Date this record was last updated' 
        } | ForEach-Object { $addTableOp.Columns.Add( $_ ) }

        if( -not $SkipRowGuidCol )
        {
            $addTableOp.Columns.Add( 
                (uniqueidentifier 'rowguid' -NotNull -RowGuidCol -Default 'newsequentialid()' -Description 'rowguid column used for replication')
            )
            $createRowGuidIndex = $true
        }

        $addTableOp.Columns.Add( (bit 'SkipBit' -Default 0 -Description 'Used to bypass custom triggers') )

        $addTableOp.pstypenames.insert( 0, 'WebMD.Rivet.Operations.AddReplicatedTableOperation' )
    }

    $addTableOp | Add-Member -MemberType NoteProperty -Name 'IsReplicated' -Value $Replicated

    $ops

    if( $createRowGuidIndex )
    {
        Add-Index -ColumnName 'rowguid' -Unique -SchemaName $addTableOp.SchemaName -TableName $addTableOp.Name
    }

    if( $Replicated )
    {
        $trigger = @'
ON [{0}].[{1}]
FOR UPDATE
NOT FOR REPLICATION
AS
IF @@ROWCOUNT = 0
    RETURN

--<< SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
SET NOCOUNT ON

--<< Update LastUpdated and SkipBit column on existing record
--<< To bypass the execution of this trigger set SkipBit = 1
IF ( (TRIGGER_NESTLEVEL(@@PROCID) = 1 AND (NOT UPDATE(SkipBit) OR EXISTS(select SkipBit from Inserted where isnull(SkipBit, 0) = 0))) )
BEGIN
    UPDATE t1
    SET
        LastUpdated = GETDATE(),
        SkipBit     = 0
    FROM [{0}].[{1}] t1
    INNER JOIN Inserted ON t1.rowguidcol = Inserted.rowguidcol
END
'@ -f $addTableOp.SchemaName,$addTableOp.Name

        Add-Trigger -SchemaName $addTableOp.SchemaName -Name ('tr{0}_Activity' -f $addTableOp.Name) -Definition $trigger
    }
}


