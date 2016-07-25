
function Merge-Migration
{
    <#
    .SYNOPSIS
    Creates a cumulative set of operations from migration scripts.

    .DESCRIPTION
    The `Merge-Migration` functions creates a cumulative set of migrations from migration scripts. If there are multiple operations across one or more migration scripts that touch the same database object, those changes are combined into one operation. For example, if you create a table in one migration, add a column in another migrations, then remove a column in a third migration, this function will output an operation that represents the final state for the object: a create table operation that includes the added column and doesn't include the removed column. In environments where tables are replicated, it is more efficient to modify objects once and have that change replicated once, than to have the same object modified multiple times and replicated multiple times.

    .OUTPUTS
    Rivet.Migration

    .EXAMPLE
    Merge-Migration 

    Demonstrates how to run `Convert-Migration.ps1`.
    #>
    [CmdletBinding()]
    [OutputType([Rivet.Migration])]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [Rivet.Migration[]]
        # The path to the rivet.json file to use. By default, it will look in the current directory.
        $Migration
    )

    begin
    {
        Set-StrictMode -Version 'Latest'

        function Get-ColumnIndex
        {
            param(
                [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
                [string]
                # The column to check for.
                $Name,

                [Parameter(Mandatory=$true)]
                [Collections.Generic.List[Rivet.Column]]
                [AllowEmptyCollection()]
                # The column collection to modify
                $List
            )

            $columnIdx = $null
            for( $idx = 0; $idx -lt $List.Count; ++$idx )
            {
                if( $List[$idx].Name -eq $Name )
                {
                    return $idx
                }
            }
        }

        filter Add-Column
        {
            param(
                [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
                [Rivet.Column]
                # The column to check for.
                $Column,

                [Parameter(Mandatory=$true)]
                [Collections.Generic.List[Rivet.Column]]
                [AllowEmptyCollection()]
                # The column collection to modify
                $List,

                [Switch]
                # Replace only, don't add.
                $ReplaceOnly
            )

            $columnIdx = Get-ColumnIndex -Name $Column.Name -List $List
            if( $columnIdx -eq $null )
            {
                if( -not $ReplaceOnly )
                {
                    [void] $List.Add( $column )
                    return $true
                }
            }
            else
            {
                $null = $List.RemoveAt( $columnIdx )
                $List.Insert( $columnIdx, $column )
                return $true
            }

            return $false
        }

        filter Remove-Column
        {
            param(
                [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
                [string]
                # The column to check for.
                $Name,

                [Parameter(Mandatory=$true)]
                [Collections.Generic.List[Rivet.Column]]
                [AllowEmptyCollection()]
                # The column collection to modify
                $List
            )

            $columnIdx = Get-ColumnIndex -Name $Name -List $List
            if( $columnIdx -ne $null )
            {
                [void] $List.RemoveAt( $columnIdx )
                return $true
            }

            return $false
        }

        $migrations = New-Object 'Collections.Generic.List[Rivet.Migration]'
        $newTables = New-Object 'Collections.Generic.HashSet[string]'
        $operations = New-Object 'Collections.ArrayList'
        $migrationOperationMap = New-Object 'Collections.ArrayList'
        $migrationOperationIdx = New-Object 'Collections.ArrayList'
        $opIdx = @{ }
    }

    process
    {
        foreach( $currentMigration in $Migration )
        {
            $migrationName = '{0}_{1}' -f $currentMigration.ID,$currentMigration.Name
            Write-Debug -Message ('{0}' -f $migrationName)

            $migrations.Add( $currentMigration )

            for( $pushOpIdx = 0; $pushOpIdx -lt $currentMigration.PushOperations.Count; ++$pushOpIdx )
            {
                function Remove-CurrentOperation
                {
                    $currentMigration.PushOperations.RemoveAt( $pushOpIdx-- )
                }

                $op = $currentMigration.PushOperations[$pushOpIdx]
                [void]$operations.Add( $op )
                [void]$migrationOperationMap.Add($currentMigration)
                [void]$migrationOperationIdx.Add($pushOpIdx)

                if( ($op | Get-Member -Name 'ObjectName') -and -not $opIdx.ContainsKey($op.ObjectName)  )
                {
                    $opIdx[$op.ObjectName] = $operations.Count - 1
                }

                if( $op -is [Rivet.Operations.AddTableOperation] )
                {
                    [void] $newTables.Add( $op.ObjectName )
                    continue
                }

                if( $op -is [Rivet.Operations.RenameColumnOperation] )
                {
                    $tableName = '{0}.{1}' -f $op.SchemaName,$op.TableName
                    if( $opIdx.ContainsKey( $tableName ) )
                    {
                        $tableOp = $operations[$opIdx[$tableName]]
                        if( $tableOp -is [Rivet.Operations.AddTableOperation] )
                        {
                            $originalColumn = $tableOp.Columns | Where-Object { $_.Name -eq $op.Name }
                            if( $originalColumn )
                            {
                                $originalColumn.Name = $op.NewName
                                Remove-CurrentOperation
                                continue
                            }
                        }
                    }
                }

                if( $op -is [Rivet.Operations.RenameOperation] )
                {
                    $objectName = '{0}.{1}' -f $op.SchemaName,$op.Name
                    if( $opIdx.ContainsKey( $objectName ) )
                    {
                        $existingOp = $operations[$opIdx[$objectName]]
                        if( $existingOp -is [Rivet.Operations.AddTableOperation] )
                        {
                            $existingOp.Name = $op.NewName
                            Remove-CurrentOperation
                            continue
                        }
                    }
                }

                if( $op -isnot [Rivet.Operations.ObjectOperation] )
                {
                    continue
                }

                if( $opIdx.ContainsKey( $op.ObjectName ) )
                {
                    $idx = $opIdx[$op.ObjectName]
                    $existingOp = $operations[$idx]
                    if( $existingOp -eq $op )
                    {
                        continue
                    }

                    $opTypeName = $op.GetType().Name
                    if( $opTypeName -like 'Remove*' )
                    {
                        $operations[$idx] = $null
                        $originalMigration = $migrationOperationMap[$idx]
                        $originalMigration.PushOperations.RemoveAt( $migrationOperationIdx[$idx] )
                        if( $originalMigration -eq $currentMigration )
                        {
                            $pushOpIdx--
                        }
                        Remove-CurrentOperation
                        continue
                    }
                    elseif( $opTypeName -eq 'UpdateTableOperation' )
                    {
                        if( $existingOp -is [Rivet.Operations.AddTableOperation] )
                        {
                            $op.AddColumns | Add-Column -List $existingOp.Columns | Out-Null
                            $op.UpdateColumns | Add-Column -List $existingOp.Columns | Out-Null
                            $op.RemoveColumns | Remove-Column -List $existingOp.Columns | Out-Null
                            Remove-CurrentOperation
                        }
                        elseif( $existingOp -is [Rivet.Operations.UpdateTableOperation] )
                        {
                            if( $op.AddColumns -and $op.AddColumns.Count -gt 0 )
                            {
                                # If adding a column that was previously removed, remove the removal
                                $op.AddColumns | 
                                    Select-Object -ExpandProperty 'Name' | 
                                    ForEach-Object {
                                        $columnName = $_
                                        $columnIdx = -1
                                        for( $idx = 0; $idx -lt $existingOp.RemoveColumns.Count; ++$idx )
                                        {
                                            if( $existingOp.RemoveColumns[$idx] -eq $columnName )
                                            {
                                                $columnIdx = $idx
                                                break
                                            }
                                        }
                                        if( $columnIdx -ge 0 )
                                        {
                                            $existingOp.RemoveColumns.RemoveAt( $columnIdx )
                                        }
                                    }

                                # Add new columns to the original operation
                                for( $colIdx = 0; $colIdx -lt $op.AddColumns.Count; ++$colIdx )
                                {
                                    Add-Column -Column $op.AddColumns[$colIdx] -List $existingOp.AddColumns | Out-Null
                                    $op.AddColumns.RemoveAt( $colIdx-- )
                                }
                            }

                            # Replace existing column definitions
                            for( $colIdx = 0; $colIdx -lt $op.UpdateColumns.Count; ++$colIdx )
                            {
                                $column = $op.UpdateColumns[$colIdx]
                                $movedToAdd = Add-Column -Column $column -List $existingOp.AddColumns -ReplaceOnly
                                $movedToUpdates = Add-Column -Column $column -List $existingOp.UpdateColumns
                                if( $movedToAdd -or $movedToUpdates )
                                {
                                    $op.UpdateColumns.RemoveAt( $colIdx-- )
                                }
                            }

                            # Remove columns
                            for( $colIdx = 0; $colIdx -lt $op.RemoveColumns.Count; ++$colIdx )
                            {
                                $columnName = $op.RemoveColumns[$colIdx]
                                $removedAnAdd = Remove-Column -List $existingOp.AddColumns -Name $columnName
                                $removedAnUpdate = Remove-Column -List $existingOp.UpdateColumns -Name $columnName
                                if( $removedAnAdd -or $removedAnUpdate )
                                {
                                    [void] $existingOp.RemoveColumns.Add( $columnName )
                                     $op.RemoveColumns.RemoveAt( $colIdx-- )
                                }
                            }

                            if( -not $op.ToQuery() )
                            {
                                Remove-CurrentOperation
                            }
                        }
                        else
                        {
                            Write-Error ('Unhandled operation of type ''{0}''.' -f $existingOp.GetType())
                        }                        
                        continue
                    }
                }
            } 
        }
    }

    end
    {
        $migrations.ToArray()
    }
}