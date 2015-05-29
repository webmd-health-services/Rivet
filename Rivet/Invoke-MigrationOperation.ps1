
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
        [Alias('Migration')]
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [Rivet.Operations.Operation]
        # The migration object to invoke.
        $Operation
    )

    begin
    {
    }

    process
    {
        Set-StrictMode -Version 'Latest'

        $query = $Operation.ToQuery()
        try
        {
            $optionalParams = @{ }
            $nonQuery = $false
            $asScalar = $false
            if( $Operation.QueryType -eq [Rivet.Operations.OperationQueryType]::NonQuery )
            {
                $optionalParams['NonQuery'] = $true
                $nonQuery = $true
            }
            elseif( $Operation.QueryType -eq [Rivet.Operations.OperationQueryType]::Scalar )
            {
                $optionalParams['AsScalar'] = $true
                $asScalar = $true
            }

            $rowCount = $null
            if( $Operation -is [Rivet.Operations.RemoveRowOperation] -and $Operation.Truncate )
            {
                $rowCount = Invoke-Query -Query ('select count(*) from [{0}].[{1}]' -f $Operation.SchemaName,$Operation.TableName) -AsScalar
            }

            $result = Invoke-Query -Query $query -Parameter $Operation.Parameters -CommandTimeout $Operation.CommandTimeout @optionalParams
            if( $nonQuery )
            {
                if( $rowCount -ne $null )
                {
                    $Operation.RowsAffected = $rowCount
                }
                else
                {
                    $Operation.RowsAffected = $result
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

        }
        catch
        {
            Write-RivetError -Message ('Migration {0} failed' -f $migrationInfo.FullName) -CategoryInfo $_.CategoryInfo.Category -ErrorID $_.FullyQualifiedErrorID -Exception $_.Exception -CallStack ($_.ScriptStackTrace) -Query $query
            throw (New-Object ApplicationException 'Migration failed.',$_.Exception)
        }

        return $Operation
    }

    end
    {
    }
}
