
function Assert-DefaultConstraint
{
    <#
    .SYNOPSIS
    Tests that a default constraint exists for a particular column and table
    #>
    [CmdletBinding(DefaultParameterSetName='ByName')]
    param(
        [Parameter(ParameterSetName='NoName')]
        # The table's schema.  Default is `dbo`.
        [string]$SchemaName = 'dbo',

        [Parameter(Mandatory,ParameterSetName='NoName')]
        # The name of the table
        [String]$TableName,

        [Parameter(Mandatory,ParameterSetName='NoName')]
        # Array of Column Names
        [String[]]$ColumnName,

        [Parameter(Position=0)]
        # The name of the constraint.
        [String]$Name,

        # The expected expression.
        [Alias('Definition')]
        [String]$Is
    )

    Set-StrictMode -Version Latest

    if( -not $Name )
    {
        Write-Warning ('Constructing constraint names will soon become obsolete. Please update usages of Assert-DefaultConstraint/ThenDefaultConstraint to pass the name of the constraint instead of the schema name, table name, and column names.')
        $Name = New-RTConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Default
    }

    $constraint = Get-DefaultConstraint -Name $Name

    $constraint | Should -Not -BeNullOrEmpty -Because ('Default constraint "{0}" not found.' -f $Name)

    if( $PSBoundParameters.ContainsKey('Expression') )
    {
        $constraint.definition | Should -Be $Is
    }
}

Set-Alias -Name 'ThenDefaultConstraint' -Value 'Assert-DefaultConstraint'