
#Requires -Version 4
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Assert-AllMigrationsReturned
{
    param(
        $MergedMigration,
        $ExpectedCount
    )

    It 'should return all the migrations' {
        $MergedMigration | Measure-Object | Select-Object -ExpandProperty 'Count' | Should Be $ExpectedCount
    }
}

function Assert-MigrationHasNoOperations
{
    param(
        [Rivet.Migration]
        $Migration
    )

    It 'should have no operations' {
        $Migration.PushOperations.Count | Should Be 0
    }
}

function Invoke-MergeMigration
{
    [OutputType([Rivet.Migration])]`
    param(
        [Parameter(Mandatory=$true)]
        [scriptblock]
        $ScriptBlock
    )

    Invoke-Command -ScriptBlock $ScriptBlock | Merge-Migration
}

function New-MigrationObject
{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [scriptblock]
        $ScriptBlock
    )

    $migration = New-Object 'Rivet.Migration' '','','',''
    Invoke-Command -ScriptBlock $ScriptBlock | ForEach-Object { $migration.PushOperations.Add( $_ ) } | Out-Null
    return $migration
}

Describe 'Merge-Migration when adding a table then adding a column' {
    $result = Invoke-MergeMigration {
        New-MigrationObject {
            Add-Table 'snafu' {
                int index -NotNull
            }
        }

        New-MigrationObject {
            Update-Table 'snafu' -AddColumn { 
                int 'newcol' -NotNull
            }
        }
    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should consolidate columns' {
        [Rivet.Operations.AddTableOperation]$op = $result[0].PushOperations[0]
        $op.Columns.Count | Should Be 2
        $op.Columns[1].Name | Should Be 'newcol'
    }

    Assert-MigrationHasNoOperations $result[1]
}

Describe 'Merge-Migration when adding a table then updating a column' {
    $result = Invoke-MergeMigration {
        New-MigrationObject {
            Add-Table 'snafu' {
                int index -NotNull
            }
        }

        New-MigrationObject {
            Update-Table 'snafu' -UpdateColumn { 
                int 'index'
            }
        }
    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should consolidate columns' {
        [Rivet.Operations.AddTableOperation]$op = $result[0].PushOperations[0]
        $op.Columns.Count | Should Be 1
        $op.Columns[0].Name | Should Be 'index'
        $op.Columns[0].NotNull | Should Be $false
    }

    Assert-MigrationHasNoOperations $result[1]
}

Describe 'Merge-Migration when adding a table then updating a column' {
    $result = Invoke-MergeMigration {
        New-MigrationObject {
            Add-Table 'snafu' {
                int index -NotNull
            }
        }

        New-MigrationObject {
            Update-Table 'snafu' -RemoveColumn 'index'
        }
    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should consolidate columns' {
        [Rivet.Operations.AddTableOperation]$op = $result[0].PushOperations[0]
        $op.Columns.Count | Should Be 0
    }

    Assert-MigrationHasNoOperations $result[1]
}

Describe 'Merge-Migration when renaming a column' {
    $result = Invoke-MergeMigration { 
        New-MigrationObject {
            Add-Table 'snafu' {
                int 'index' -NotNull
            }
        }

        New-MigrationObject {
            Rename-Column 'snafu' 'index' 'newindex' 
        }
    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should rename the column' {
        $result[0].PushOperations[0].Columns[0].Name | Should Be 'newindex'
    }

    Assert-MigrationHasNoOperations $result[1]
}


Describe 'Merge-Migration when renaming a table' {
    $result = Invoke-MergeMigration { 
        New-MigrationObject {
            Add-Table 'snafu' {
                int 'index' -NotNull
            }
        }

        New-MigrationObject {
            Rename-Object 'snafu' 'fubar'
        }
    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should rename the table' {
        $result[0].PushOperations[0].Name | Should Be 'fubar'
    }

    Assert-MigrationHasNoOperations $result[1]
}

Describe 'Merge-Migration when removing an object' {
    $result = Invoke-MergeMigration { 
        New-MigrationObject {
            Add-Table 'snafu' {
                int 'index' -NotNull
            }
        }

        New-MigrationObject {
            Remove-Table 'snafu'
        }
    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    Assert-MigrationHasNoOperations -Migration $result[0]
    Assert-MigrationHasNoOperations -Migration $result[1]
}


Describe 'Merge-Migration when removing an object in the same migration it was created' {
    $Global:Error.Clear()

    $result = Invoke-MergeMigration { 
        New-MigrationObject {
            Add-Table 'snafu' {
                int 'index' -NotNull
            }

            Remove-Table 'snafu'
        }
    }

    $Global:Error.Count | Should Be 0

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 1

    Assert-MigrationHasNoOperations -Migration $result[0]
}

Describe 'Merge-Migration when updating a table' {

    $result = Invoke-MergeMigration {
        New-MigrationObject {
            Update-Table 'fubar' -AddColumn {
                int 'col1'
            }
        }

        New-MigrationObject {
            Update-Table 'fubar' -AddColumn {
                int 'col2'
            }
        }
    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should consolidate second added column into first migration' {
        $result[0].PushOperations[0].AddColumns.Count | Should Be 2
        $result[0].PushOperations[0].AddColumns[1].Name | Should Be 'col2'
    }

    Assert-MigrationHasNoOperations -Migration $result[1]
}

Describe 'Merge-Migration when adding a column that was removed' {

    $result = Invoke-MergeMigration {
        New-MigrationObject {
            Update-Table 'fubar' -RemoveColumn 'removemeforreal','removemebymistake'
        }

        New-MigrationObject {
            Update-Table 'fubar' -AddColumn {
                int 'removemebymistake'
            }
        }
    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should consolidate re-add into first migration' {
        $result[0].PushOperations[0].RemoveColumns.Count | Should Be 1
        $result[0].PushOperations[0].RemoveColumns[0] | Should Be 'removemeforreal'
        $result[0].PushOperations[0].AddColumns.Count | Should Be 1
        $result[0].PushOperations[0].AddColumns[0].Name | Should Be 'removemebymistake'
    }

    Assert-MigrationHasNoOperations -Migration $result[1]
}

Describe 'Merge-Migation when removing an updated column' {
    $result = Invoke-MergeMigration {
        New-MigrationObject {
            Update-Table 'fubar' -UpdateColumn {
                int 'toberemoved'
            }
        }

        New-MigrationObject {
            Update-Table 'fubar' -RemoveColumn 'toberemoved'
        }

    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should consolidate removal into first migration' {
        $result[0].PushOperations[0].RemoveColumns.Count | Should Be 1
        $result[0].PushOperations[0].RemoveColumns[0] | Should Be 'toberemoved'
        $result[0].PushOperations[0].UpdateColumns.Count | Should Be 0
    }

    Assert-MigrationHasNoOperations -Migration $result[1]
}

Describe 'Merge-Migation when removing an added column' {
    $result = Invoke-MergeMigration {
        New-MigrationObject {
            Update-Table 'fubar' -AddColumn {
                int 'toberemoved'
            }
        }

        New-MigrationObject {
            Update-Table 'fubar' -RemoveColumn 'toberemoved'
        }

    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should consolidate removal into first migration' {
        $result[0].PushOperations[0].RemoveColumns.Count | Should Be 1
        $result[0].PushOperations[0].RemoveColumns[0] | Should Be 'toberemoved'
        $result[0].PushOperations[0].AddColumns.Count | Should Be 0
    }

    Assert-MigrationHasNoOperations -Migration $result[1]
}


Describe 'Merge-Migation when updating an added column' {
    $result = Invoke-MergeMigration {
        New-MigrationObject {
            Update-Table 'fubar' -AddColumn {
                int 'tobeupdated'
            }
        }

        New-MigrationObject {
            Update-Table 'fubar' -UpdateColumn { int 'tobeupdated' -NotNull }
        }

    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should move second update to first migration' {
        $result[0].PushOperations[0].UpdateColumns.Count | Should Be 1
        $result[0].PushOperations[0].UpdateColumns[0].Name | Should Be 'tobeupdated'
        $result[0].PushOperations[0].UpdateColumns[0].Null | Should Be $false
    }

    Assert-MigrationHasNoOperations -Migration $result[1]
}


Describe 'Merge-Migation when updating an updated' {
    $result = Invoke-MergeMigration {
        New-MigrationObject {
            Update-Table 'fubar' -UpdateColumn {
                int 'tobeupdated'
            }
        }

        New-MigrationObject {
            Update-Table 'fubar' -UpdateColumn { int 'tobeupdated' -NotNull }
        }

    }

    Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

    It 'should move second update to first migration' {
        $result[0].PushOperations[0].UpdateColumns.Count | Should Be 1
        $result[0].PushOperations[0].UpdateColumns[0].Name | Should Be 'tobeupdated'
        $result[0].PushOperations[0].UpdateColumns[0].NotNull | Should Be $true
    }

    Assert-MigrationHasNoOperations -Migration $result[1]
}

