
function Set-DefaultConstraintName
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Rivet.Column]$Column,

        [Parameter(Mandatory)]
        [String]$SchemaName,

        [Parameter(Mandatory)]
        [String]$TableName
    )

    process
    {
        Set-StrictMode -Version 'Latest'

        if( -not $Column.DefaultExpression )
        {
            $Column.DefaultConstraintName = $null
            return $Column
        }

        if( $Column.DefaultExpression -and $Column.DefaultConstraintName )
        {
            return $Column
        }
        
        if( $Column.DefaultExpression -and -not $Column.DefaultConstraintName )
        {
            $Column.DefaultConstraintName = New-ConstraintName -Default -SchemaName $SchemaName -TableName $TableName -ColumnName $Column.Name
            Write-Warning -Message ('Columns with a default expression must also be given a default constraint name. ' +
                                    "Please update the [$($SchemaName)].[$($TableName)] table''s [$($Column.Name)] " +
                                    'column to include a DefaultConstraintName parameter with a value of ' +
                                   """$($Column.DefaultConstraintName)"".")
        }

        return $Column
    }
}
