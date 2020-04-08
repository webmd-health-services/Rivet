function Merge-Migration
{
    <#
    .SYNOPSIS
    Creates a cumulative set of operations from migration scripts.

    .DESCRIPTION
    The `Merge-Migration` functions creates a cumulative set of migrations from migration scripts. If there are multiple operations across one or more migration scripts that touch the same database object, those changes are combined into one operation. For example, if you create a table in one migration, add a column in another migrations, then remove a column in a third migration, this function will output an operation that represents the final state for the object: a create table operation that includes the added column and doesn't include the removed column. In environments where tables are replicated, it is more efficient to modify objects once and have that change replicated once, than to have the same object modified multiple times and replicated multiple times.

    This function returns `Rivet.Migration` objects. Each object will have zero or more operations in its `PushOperations` property. If there are zero operations, it means the original operation was consolidated into another migration. Each operation has `Source` member on it, which is a list of all the migrations that contributed to that operation. 

    .OUTPUTS
    Rivet.Migration

    .EXAMPLE
    Get-Migration | Merge-Migration 

    Demonstrates how to run `Merge-Migration`. It is always used in conjunction with `Get-Migration`.
    #>
    [CmdletBinding()]
    [OutputType([Rivet.Migration])]
    param(
        [Parameter(ValueFromPipeline)]
        # The path to the rivet.json file to use. By default, it will look in the current directory.
        [Rivet.Migration[]]$Migration
    )

    begin
    {
        Set-StrictMode -Version 'Latest'

        # Collect all the migrations. We can't merge anything until we get to the end.
        [Collections.ArrayList]$migrations = [Collections.ArrayList]::New()
    }

    process
    {
        foreach( $migrationItem in $Migration )
        {
            [void]$migrations.Add($migrationItem)
        }
    }

    end
    {
        [Rivet.Operation[]]$operations = $migrations | Select-Object -ExpandProperty 'PushOperations'

        if( $operations )
        {
            # Merge each operation with all the operations that preceded it (so don't include the first).
            for( $currentOpIdx = $operations.Count - 1; $currentOpIdx -gt 0; --$currentOpIdx )
            {
                $currentOp = $operations[$currentOpIdx]

                for( $visitingIdx = $currentOpIdx - 1; $visitingIdx -ge 0; --$visitingIdx )
                {
                    $operations[$visitingIdx].Merge($currentOp)
                }
            }
        }

        # Now, remove all the disabled operations.
        foreach( $migrationItem in $migrations )
        {
            for( $idx = $migrationItem.PushOperations.Count - 1; $idx -ge 0 ; --$idx )
            {
                $operation = $migrationItem.PushOperations[$idx]
                if( $operation.Disabled )
                {
                    $migrationItem.PushOperations.RemoveAt($idx)    
                }
            }
        }

        Write-Output $migrations.ToArray()
    }
}