
function Invoke-MigrationOperation
{
    <#
    .SYNOPSIS
    Runs the SQL created by a `Rivet.Migration` object.

    .DESCRIPTION
    All Rivet migrations are described by instances of `Rivet.Migration` objects.  These objects eventually make their way here, at which point they are converted to SQL, and executed.

    .EXAMPLE
    Invoke-Migration -Operation $operation

    This example demonstrates how to call `Invoke-Migration` with a migration object.
    #>
    [CmdletBinding(DefaultParameterSetName='AsReader')]
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session,

        # The migration this operation is from.
        [Parameter(Mandatory)]
        [Rivet.Migration] $Migration,

        # The migration object to invoke.
        [Parameter(Mandatory, ValueFromPipeline)]
        [Rivet.Operations.Operation] $Operation
    )

    begin
    {
    }

    process
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

        $optionalArgs = @{ }
        $nonQuery = $false
        $asScalar = $false
        if( $Operation.QueryType -eq [Rivet.OperationQueryType]::NonQuery -or $Operation.QueryType -eq [Rivet.OperationQueryType]::Ddl )
        {
            $optionalArgs['NonQuery'] = $true
            $nonQuery = $true
        }
        elseif( $Operation.QueryType -eq [Rivet.OperationQueryType]::Scalar )
        {
            $optionalArgs['AsScalar'] = $true
            $asScalar = $true
        }

        $Operation.ToQuery() |
            Split-SqlBatchQuery -Verbose:$false |
            Where-Object { $_ } |
            ForEach-Object {

                $batchQuery = $_
                $result = $null
                $rowsAffected = -1
                $rowCount = $null

                if( $Operation -is [Rivet.Operations.RemoveRowOperation] -and $Operation.Truncate)
                {
                    $query = "select count(*) from [$($Operation.SchemaName)].[$($Operation.TableName)]"
                    $rowCount = Invoke-Query -Session $Session -Query $query -AsScalar
                }

                $result =
                    Invoke-Query -Session $Session -Query $batchQuery -Parameter $Operation.Parameters @optionalArgs

                if( $nonQuery )
                {
                    if ($null -eq $rowCount)
                    {
                        $rowsAffected = $result
                    }
                }
                elseif( $asScalar )
                {
                    if( $result -ne 0 )
                    {
                        if ($Operation -is [Rivet.Operations.UpdateCodeObjectMetadataOperation])
                        {
                            $exMsg = "Failed to refresh [$($Operation.SchemaName)].[$($Operation.Name)]"
                        }
                        elseif ($Operation -is [Rivet.Operations.RenameColumnOperation])
                        {
                            $exMsg = "Failed to rename column {0}.{1}.{2} to {0}.{1}.{3}" -f $Operation.SchemaName,$Operation.TableName,$Operation.Name,$Operation.NewName
                        }
                        elseif ($Operation -is [Rivet.Operations.RenameOperation])
                        {
                            $exMsg = "Failed to rename object {0}.{1} to {0}.{2}" -f $Operation.SchemaName,$Operation.Name,$Operation.NewName
                        }
                        throw ('{0}: error code {1}' -f $exMsg,$result)
                    }
                }

                return [Rivet.OperationResult]::New($Migration, $Operation, $batchQuery, $rowsAffected)
            }
    }

    end
    {
    }
}
