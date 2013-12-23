<#
.SYNOPSIS
Demonstrates how to use the Rivet object model to convert migrations to standalone SQL scripts.

.DESCRIPTION
Sometimes you can't run your migration scripts directly against a database.  In these situations, it is useful to be able to grab the SQL from your migrations and convert them into a different form.  This script demonstates how to do that by outputing your migrations into four different files per database: one for schema changes, one for code object changes, one for data, and one for unknown kinds of changes.

.EXAMPLE
Convert-Migration.ps1 -OutputPath 'F:\BuildOutput\DBScripts'

Demonstrates how to run `Convert-Migration.ps1`.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]
    # The directory where the scripts should be output.
    $OutputPath,

    [Parameter()]
    [string]
    # The path to the rivet.json file to use.  By default, it will look in the current directory.
    $ConfigFilePath,

    [string[]]
    # A list of migrations to include. Only migrations that match are returned.  Wildcards permitted.
    $Include,

    [string[]]
    # Any migrations/files to exclude.  Wildcards accepted.
    $Exclude,

    [DateTime]
    # Only get migrations before this date/time.
    $Before,

    [DateTime]
    # Only get migrations after this date/time.
    $After
)

Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath '..\Import-Rivet.ps1' -Resolve)

if( -not (Test-Path -Path $OutputPath -PathType Container) )
{
    $null = New-Item -ItemType 'Directory' -Path $OutputPath -Force
}
else
{
    Get-ChildItem -Path $OutputPath -File | Remove-Item
}

$getMigrationParams = @{ }
@( 'ConfigFilePath', 'Exclude', 'Include', 'Before', 'After' ) |
    Where-Object { $PSBoundParameters.ContainsKey( $_ ) } |
    ForEach-Object { $getMigrationParams.$_ = Get-Variable -Name $_ -ValueOnly }

$operations = New-Object 'Collections.ArrayList'
$opIdx = @{ }

Get-Migration @getMigrationParams |
    ForEach-Object { 
        $migration = $_
        $migrationName = '{0}_{1}' -f $migration.ID,$migration.Name

        $migration.PushOperations |
            Add-Member -MemberType NoteProperty -Name 'Migrations' -Value @() -PassThru |
            Add-Member -MemberType NoteProperty -Name 'Database' -Value $migration.Database -PassThru |
            ForEach-Object {
                $op = $_
                $op.Migrations += $migrationName

                if( $op -isnot [Rivet.Operations.ObjectOperation] )
                {
                    $null = $operations.Add( $op )
                    return
                }

                if( $opIdx.ContainsKey( $op.ObjectName ) )
                {
                    $idx = $opIdx[$op.ObjectName]
                    $existingOp = $operations[$idx]

                    $opTypeName = $op.GetType().Name
                    if( $opTypeName -like 'Remove*' )
                    {
                        $operations[$idx] = $null
                        return
                    }
                    elseif( $opTypeName -eq 'UpdateTableOperation' )
                    {
                        $addTableOp = $existingOp
                        if( $addTableOp.Migrations -notcontains $migrationName )
                        {
                            $addTableOp.Migrations += $migrationName
                        }
                        $colIdx = @{ }
                        $idx = 0
                        $addTableOp.Columns | ForEach-Object { $colIdx[$_.Name] = $idx++ }
                        Invoke-Command {
                                    $op.AddColumns
                                    $op.UpdateColumns
                                } | 
                            ForEach-Object {
                                $column = $_
                                $columnIdx = $null
                                if( $colIdx.ContainsKey( $column.Name ) )
                                {
                                    $columnIdx = $colIdx[$column.Name]
                                }

                                if( $columnIdx -eq $null )
                                {
                                    $addTableOp.Columns.Add( $column )
                                }
                                else
                                {
                                    $null = $addTableOp.Columns.RemoveAt( $columnIdx )
                                    $addTableOp.Columns.Insert( $columnIdx, $column )
                                }
                            }
                        $op.RemoveColumns | 
                            Where-Object { $colIdx.ContainsKey( $_ ) } |
                            ForEach-Object { $null = $addTableOp.Columns.RemoveAt( $colIdx[$_] ) }
                        return
                    }
                }

                $null = $operations.Add( $op )
                $opIdx[$op.ObjectName] = $operations.Count - 1
            } 
    }
    

    # Now, output the cumulative changes.
    $operations | Where-Object { $_ } | ForEach-Object {

        $op = $_

        $schemaScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Schema.sql' -f $op.Database)
        $codeObjectScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.CodeObject.sql' -f $op.Database)
        $dataScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Data.sql' -f $op.Database)
        $unknownScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Unknown.sql' -f $op.Database)

        $header = @'
-- {0}
'@ -f ($op.Migrations -join "`n-- ")

            $op = $_
            $path = switch -Regex ( $op.GetType() )
            {
                '(Add|Remove|Update)(CheckConstraint|DataType|DefaultConstraint|ExtendedProperty|ForeignKey|Index|PrimaryKey|Schema|Table|Trigger|UniqueKey|Column)'
                {
                    if( $Matches[2] -eq 'ExtendedProperty' -and $op.ForView )
                    {
                        $codeObjectScriptPath
                    }
                    else
                    {
                        $schemaScriptPath
                    }
                    break
                }

                'Rename(Column|Constraint|Index)?Operation'
                {
                    $schemaScriptPath
                }

                '(Add|Remove|Update)(StoredProcedure|Synonym|UserDefinedFunction|View)'
                {
                    $codeObjectScriptPath
                    break
                }

                '(Add|Remove|Update)Row'
                {
                    $dataScriptPath
                    break
                }

                'RawQuery'
                {
                    Write-Warning ('Generic migration operation found in ''{0}''.' -f $migration.Path)
                    $unknownScriptPath
                    break
                }

                default
                {
                    Write-Error ('Unknown migration operation ''{0}'' in ''{1}''.' -f $op.GetType(),$migration.Path)
                    return
                }
            }

            if( -not (Test-Path -Path $path -PathType Leaf) )
            {
                $null = New-Item -Path $path -ItemType 'File' -Force
            }
            $header | Add-Content -Path $path
            $op.ToIdempotentQuery() | Add-Content -Path $path
            ("GO{0}" -f [Environment]::NewLine) | Add-Content -Path $path
        }
