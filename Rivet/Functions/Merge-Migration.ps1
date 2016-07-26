
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
        # list of every single operation we encounter across migrations
        $operations = New-Object 'Collections.ArrayList'
        # The migration each operation came from. 
        $operationToMigrationMap = New-Object 'Collections.ArrayList'
        # The index of the operation in its migration's PushOperations list.
        $migrationPushOperationIdx = New-Object 'Collections.ArrayList'
        $opIdx = @{ }
    }

    process
    {

        #$DebugPreference = 'Continue'

        foreach( $currentMigration in $Migration )
        {
            function Register-Source
            {
                [CmdletBinding()]
                param(
                    [Rivet.Operation]
                    $Operation
                )
                    
                Set-StrictMode -Version 'Latest'

                Write-Debug -Message     ('Current Migration Name: <{0}>' -f $migrationName)
                Write-Debug -Message     ('Operation Type:         <{0}>' -f $Operation.GetType().FullName)
                Write-Debug -Message     ('Start Source Count:     <{0}>' -f $Operation.Source.Count)
                foreach( $source in $Operation.Source )
                {
                    Write-Debug -Message ('Source Migration Name:  <{0}>' -f $source.FullName)
                    if( $source.FullName -eq $migrationName )
                    {
                        return
                    }
                }

                $Operation.Source.Add( $currentMigration )
                Write-Debug -Message     ('End Source Count:       <{0}>' -f $Operation.Source.Count)
            }

            $migrationName = '{0}_{1}' -f $currentMigration.ID,$currentMigration.Name
            Write-Debug -Message ('{0}' -f $migrationName)

            $migrations.Add( $currentMigration )

            $pushOpIdx = 0
            for( $pushOpIdx = 0; $pushOpIdx -lt $currentMigration.PushOperations.Count; ++$pushOpIdx )
            {
                function Remove-CurrentOperation
                {
                    $currentMigration.PushOperations.RemoveAt( $pushOpIdx )
                    Set-Variable -Name 'pushOpIdx' -Scope 1 -Value ($pushOpIdx - 1)
                }

                $op = $currentMigration.PushOperations[$pushOpIdx]
                [void]$operations.Add( $op )
                [void]$operationToMigrationMap.Add($currentMigration)
                [void]$migrationPushOperationIdx.Add($pushOpIdx)
                $source = New-Object -TypeName 'Collections.Generic.List[Rivet.Migration]'
                $op | Add-Member -Name 'Source' -MemberType NoteProperty -Value $source
                Register-Source $op

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
                                Register-Source $tableOp
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
                            Register-Source $existingOp
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

                    Register-Source $existingOp

                    $opTypeName = $op.GetType().Name
                    if( $opTypeName -like 'Remove*' )
                    {
                        $operations[$idx] = $null
                        $opIdx.Remove($op.ObjectName)
                        $originalMigration = $operationToMigrationMap[$idx]
                        $originalMigration.PushOperations.RemoveAt( $migrationPushOperationIdx[$idx] )
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
                                $moved = Add-Column -Column $column -List $existingOp.AddColumns -ReplaceOnly
                                $moved = $moved -or (Add-Column -Column $column -List $existingOp.UpdateColumns)
                                if( $moved )
                                {
                                    $op.UpdateColumns.RemoveAt( $colIdx-- )
                                }
                            }

                            # Remove columns
                            for( $colIdx = 0; $colIdx -lt $op.RemoveColumns.Count; ++$colIdx )
                            {
                                $columnName = $op.RemoveColumns[$colIdx]
                                # Remove a column we previously added
                                $removedFromAddedColumns = Remove-Column -List $existingOp.AddColumns -Name $columnName
                                $removedFromUpdatedColumns = Remove-Column -List $existingOp.UpdateColumns -Name $columnName

                                $op.RemoveColumns.RemoveAt( $colIdx-- )
                                if( -not ($removedFromAddedColumns -or $removedFromUpdatedColumns) )
                                {
                                    [void] $existingOp.RemoveColumns.Add( $columnName )
                                }
                            }

                            if( -not $op.ToQuery() )
                            {
                                Remove-CurrentOperation
                            }

                            if( -not $existingOp.ToQuery() )
                            {
                                $existingOp.Source[0].PushOperations.RemoveAt( $migrationPushOperationIdx[$idx] )
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