
function Assert-Column
{
    param(
        [Parameter(Position=0, Mandatory)]
        [String] $Name,

        [Parameter(Position=1, Mandatory)]
        [String]
        $DataType,

        $Description,

        [switch] $Max,

        [int] $Size,

        [int] $Precision,

        [int] $Scale,

        [switch] $Sparse,

        [switch] $NotNull,

        [int] $Seed,

        [int] $Increment,

        [switch] $NotForReplication,

        [switch] $RowGuidCol,

        [switch] $Document,

        [switch] $FileStream,

        [String] $Collation,

        [Object] $Default,

        [Parameter(Mandatory)]
        [String] $TableName,

        [Alias('TableSchema')]
        [String] $SchemaName = 'dbo',

        [String] $DefaultConstraintName,

        [String] $DatabaseName
    )

    Set-StrictMode -Version Latest

    $column = Get-Column -SchemaName $SchemaName -TableName $TableName -Name $Name -DatabaseName $DatabaseName

    $column | Should -Not -BeNullOrEmpty

    $column.type_name | Should -Be $DataType

    if( $Max )
    {
        $column.max_length | Should -Be -1
    }

    if( $Size )
    {
        if( $column.type_name -like 'n*char' )
        {
            ($column.max_length / 2) | Should -Be $Size
        }
        else
        {
            $column.max_length | Should -Be $Size
        }
    }

    if( $Precision )
    {
        $column.precision | Should -Be $Precision
    }

    if( $Scale )
    {
        $column.scale | Should -Be $Scale
    }

    if( $NotNull )
    {
        $column.is_nullable | Should -BeFalse
    }
    else
    {
        $column.is_nullable | Should -BeTrue
    }

    if( $PSBoundParameters.ContainsKey('Description') )
    {
            $column.MSDescription | Should -Be $Description
    }

    if( $Default )
    {
        $column.default_constraint | Should -Not -BeNullOrEmpty
        if (-not $DefaultConstraintName)
        {
            $DefaultConstraintName = New-RTConstraintName -SchemaName $SchemaName -TableName $TableName -ColumnName $Name -Default
        }
        $column.default_constraint_name | Should -Be $DefaultConstraintName
        $column.default_constraint | Should -Match ('{0}' -f ([Text.RegularExpressions.Regex]::Escape($Default)))
    }

    if( $Seed -or $Increment )
    {
        $column.is_identity | Should -BeTrue
        if( $Seed )
        {
            $column.seed_value | Should -Be $Seed
        }

        if( $Increment )
        {
            $column.increment_value | Should -Be $Increment
        }
    }

    if( $RowGuidCol )
    {
        $column.is_rowguidcol | Should -BeTrue
    }
    else
    {
        $column.is_rowguidcol | Should -BeFalse
    }

    if( $Document )
    {
        $column.is_xml_document | Should -BeTrue
    }

    if( $FileStream )
    {
        $column.is_filestream | Should -BeTrue
    }

    if( $Collation )
    {
        $column.collation_name | Should -Be $Collation
    }

    if( $Sparse )
    {
        $column.is_sparse | Should -BeTrue
    }

    if( $NotForReplication )
    {
        $column.is_not_for_replication | Should -BeTrue
    }
}
