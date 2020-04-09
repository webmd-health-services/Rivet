
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
        # The migration this operation is from.
        [Rivet.Migration]$Migration,

        [Parameter(Mandatory,ValueFromPipeline)]
        # The migration object to invoke.
        [Rivet.Operations.Operation]$Operation
    )

    begin
    {
    }

    process
    {
        Set-StrictMode -Version 'Latest'

        $optionalParams = @{ }
        $nonQuery = $false
        $asScalar = $false
        if( $Operation.QueryType -eq [Rivet.OperationQueryType]::NonQuery -or $Operation.QueryType -eq [Rivet.OperationQueryType]::Ddl )
        {
            $optionalParams['NonQuery'] = $true
            $nonQuery = $true
        }
        elseif( $Operation.QueryType -eq [Rivet.OperationQueryType]::Scalar )
        {
            $optionalParams['AsScalar'] = $true
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

                try
                {
                    if( $Operation -is [Rivet.Operations.RemoveRowOperation] -and $Operation.Truncate )
                    {
                        $rowCount = Invoke-Query -Query ('select count(*) from [{0}].[{1}]' -f $Operation.SchemaName,$Operation.TableName) -AsScalar
                    }

                    $result = Invoke-Query -Query $batchQuery -Parameter $Operation.Parameters -CommandTimeout $Operation.CommandTimeout @optionalParams
                }
                catch
                {
                    Write-RivetError -Message ('Migration {0} failed' -f $migrationInfo.FullName) `
                                        -CategoryInfo $_.CategoryInfo.Category `
                                        -ErrorID $_.FullyQualifiedErrorID `
                                        -Exception $_.Exception `
                                        -CallStack ($_.ScriptStackTrace) `
                                        -Query $batchQuery
                    throw (New-Object ApplicationException 'Migration failed.',$_.Exception)
                }

                if( $nonQuery )
                {
                    if( $rowCount -eq $null )
                    {
                        $rowsAffected = $result
                    }
                }
                elseif( $asScalar )
                {
                    if( $result -ne 0 )
                    {
                        if( $Operation -is [Rivet.Operations.UpdateCodeObjectMetadataOperation] )
                        {
                            $exMsg = "Failed to refresh {0}.{1}" -f $Operation.SchemaName,$Operation.Name
                        }
                        elseif( $Operation -is [Rivet.Operations.RenameColumnOperation] )
                        {
                            $exMsg = "Failed to rename column {0}.{1}.{2} to {0}.{1}.{3}" -f $Operation.SchemaName,$Operation.TableName,$Operation.Name,$Operation.NewName
                        }
                        elseif( $Operation -is [Rivet.Operations.RenameOperation] )
                        {
                            $exMsg = "Failed to rename object {0}.{1} to {0}.{2}" -f $Operation.SchemaName,$Operation.Name,$Operation.NewName
                        }
                        throw ('{0}: error code {1}' -f $exMsg,$result)
                    }
                }
                        
                return New-Object 'Rivet.OperationResult' $Migration,$Operation,$batchQuery,$rowsAffected              
            }
    }

    end
    {
    }
}
