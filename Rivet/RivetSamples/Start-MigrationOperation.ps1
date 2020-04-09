
function Start-MigrationOperation
{
    [CmdletBinding()]
    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
    param(
        [Parameter(Mandatory=$true)]
        [Rivet.Migration]
        # The migration the operation is part of.
        $Migration,

        [Parameter(Mandatory=$true)]
        [Rivet.Operations.Operation]
        # The operation which is about to be applied.
        $Operation
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    
    function Test-DescriptionOperation
    {
        $Operation.ChildOperations | 
            Where-Object { $_ -is [Rivet.Operations.AddExtendedPropertyOperation] } |
            Where-Object { $_.Name -eq [Rivet.Operations.ExtendedPropertyOperation]::DescriptionPropertyName } |
            Where-Object { $_.SchemaName -eq $Operation.SchemaName } |
            Where-Object { $_.TableViewName -eq $Operation.Name }
    }

    $problems = $false
    if( ($Operation -is [Rivet.Operations.AddTableOperation]) )
    {
        if( -not (Test-DescriptionOperation) )
        {
            Write-Error ('Table {0}''s description not found.  Please pass a value to the `Add-Table` function''s `-Description` parameter.' -f $Operation.Name)
            $problems = $true
        }

        Invoke-Command {
            smalldatetime 'CreateDate' -NotNull -Default 'getdate()' -Description 'Record created date'
            datetime 'LastUpdated' -NotNull -Default 'getdate()' -Description 'Date this record was last updated' 
        } | ForEach-Object { $Operation.Columns.Add( $_ ) }

        $skipRowGuidCol = $Operation.Columns | 
                            Where-Object { $_.DataType -eq [Rivet.DataType]::UniqueIdentifier } |
                            Where-Object { $_.RowGuidCol }
        if( -not $skipRowGuidCol )
        {
            $Operation.Columns.Add( 
                (uniqueidentifier 'rowguid' -NotNull -RowGuidCol -Default 'newsequentialid()' -Description 'rowguid column used for replication')
            )

        }

        $Operation.Columns.Add( (bit 'SkipBit' -Default 0 -Description 'Used to bypass custom triggers') )
    }

    if( ($Operation -is [Rivet.Operations.AddTableOperation]) -or ($Operation -is [Rivet.Operations.UpdateTableOperation]) )
    {
        ('Columns','AddColumns') | 
            Where-Object { $Operation | Get-Member $_ } |
            ForEach-Object { $Operation | Select-Object -ExpandProperty $_ } |
            Where-Object { -not $_.Description } |
            ForEach-Object {
                Write-Error ('Table {0}: column {1}''s description not found.  Please supply a value to the {2} function''s `-Description` parameter.' -f $Operation.Name,$_.Name,$_.DataType.ToString().ToLowerInvariant())
                $problems = $true
            }

        ('Columns','AddColumns','UpdateColumns') | 
            Where-Object { $Operation | Get-Member $_ } |
            ForEach-Object { $Operation | Select-Object -ExpandProperty $_ } |
            ForEach-Object {
                if( $_.Identity )
                {
                    if( $_.DataType -ne [Rivet.DataType]::Int )
                    {
                        Write-Error ('Table {0}: column {1}: {2} columns can''t be identity columns.  Please remove the identity specification or change the column type to int.' -f $Operation.Name,$_.Name,$_.DataType)
                        $problems = $true
                    }

                    $_.Identity.NotForReplication = $true
                }
            }
    }

    if( $Operation -is [Rivet.Operations.AddForeignKeyOperation] -or $Operation -is [Rivet.Operations.AddCheckConstraintOperation] )
    {
        $Operation.NotForReplication = $true
    }

    if( $Operation -is [Rivet.Operations.AddTriggerOperation] -or $Operation -is [Rivet.Operations.UpdateTriggerOperation] )
    {
        if( $Operation.Definition -notmatch 'not for replication' )
        {
            Write-Error ('Trigger {0}: all user-defined triggers must have ''not for replication'' clause specified.  Please add the ''not for replication'' clause to your trigger.' -f $_.Name)
            $problems = $true
        }
    }

    if( $problems )
    {
        throw ('There were errors running ''{0}''.  Please see previous errors for details.' -f $Operation.GetType().Name)
    }
}
