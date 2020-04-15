
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

function Assert-AllMigrationsReturned
{
    param(
        $MergedMigration,
        $ExpectedCount
    )

    $MergedMigration | Measure-Object | Select-Object -ExpandProperty 'Count' | Should -Be $ExpectedCount
}

function Assert-MigrationHasNoOperations
{
    param(
        [Rivet.Migration]$Migration
    )

    $Migration.PushOperations | Should -HaveCount 0
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
        [string]
        $Name,

        [Parameter(Mandatory=$true,Position=1)]
        [scriptblock]
        $ScriptBlock,

        [string]
        $DatabaseName = 'dbname'
    )

    $id = Get-Date -UFormat '%Y%m%d%H%M%S'
    $path = '{0}_{1}' -f $id,$Name
    $migration = New-Object 'Rivet.Migration' $id,$Name,$path,$DatabaseName
    Invoke-Command -ScriptBlock $ScriptBlock | ForEach-Object { $migration.PushOperations.Add( $_ ) } | Out-Null
    return $migration
}

Describe 'Merge-Migration.when adding a table then adding a column' {
    It 'should add column to table definition' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'AddTable' {
                Add-Table 'snafu' {
                    int index -NotNull
                }
            }

            New-MigrationObject 'AddColumn' {
                Update-Table 'snafu' -AddColumn { 
                    int 'newcol' -NotNull
                }
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        [Rivet.Operations.AddTableOperation]$op = $result[0].PushOperations[0]
        $op.Columns.Count | Should -Be 2
        $op.Columns[1].Name | Should -Be 'newcol'

        Assert-MigrationHasNoOperations $result[1]
    }
}

Describe 'Merge-Migration.when adding a table then updating a column' {
    It 'should use updated column definition in original migration' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'AddTable' {
                Add-Table 'snafu' {
                    int index -NotNull
                }
            }

            New-MigrationObject 'UpdateColumn' {
                Update-Table 'snafu' -UpdateColumn { 
                    int 'index'
                }
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        [Rivet.Operations.AddTableOperation]$op = $result[0].PushOperations[0]

        $op.Columns.Count | Should -Be 1
        $op.Columns[0].Name | Should -Be 'index'
        $op.Columns[0].NotNull | Should -BeFalse

        Assert-MigrationHasNoOperations $result[1]
    }
}

Describe 'Merge-Migration.when adding a table then removing a column' {
    It 'should remove column from add table operation' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'AddTable' {
                Add-Table 'snafu' {
                    int index -NotNull
                }
            }

            New-MigrationObject 'RemoveColumn' {
                Update-Table 'snafu' -RemoveColumn 'index'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        [Rivet.Operations.AddTableOperation]$op = $result[0].PushOperations[0]

        $op.Columns.Count | Should -Be 0

        Assert-MigrationHasNoOperations $result[1]
    }
}

Describe 'Merge-Migration.when renaming a column' {
    It 'should update column name in original operation' {
        $result = Invoke-MergeMigration { 
            New-MigrationObject 'AddTable' {
                Add-Table 'snafu' {
                    int 'index' -NotNull
                }
            }

            New-MigrationObject 'RenameColumn' {
                Rename-Column 'snafu' 'index' 'newindex' 
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        $op = $result[0].PushOperations[0]

        $op.Columns[0].Name | Should -Be 'newindex'

        Assert-MigrationHasNoOperations $result[1]
    }
}

Describe 'Merge-Migration.when renaming a table' {
    It 'should update table name in add table operation' {
        $result = Invoke-MergeMigration { 
            New-MigrationObject 'AddTable' {
                Add-Table 'snafu' {
                    int 'index' -NotNull
                }
            }

            New-MigrationObject 'RenameTable' {
                Rename-Object 'snafu' 'fubar'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        $op = $result[0].PushOperations[0]

        $op.Name | Should -Be 'fubar'

        Assert-MigrationHasNoOperations $result[1]
    }
}

Describe 'Merge-Migration.when removing adding and removing the same table' {
    It 'should remove both add and remove operation' {
        $result = Invoke-MergeMigration { 
            New-MigrationObject 'AddTable' {
                Add-Table 'snafu' {
                    int 'index' -NotNull
                }
            }

            New-MigrationObject 'RemoveTable' {
                Remove-Table 'snafu'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        Assert-MigrationHasNoOperations -Migration $result[0]
        Assert-MigrationHasNoOperations -Migration $result[1]
    }
}

Describe 'Merge-Migration.when removing an object in the same migration it was created' {
    It 'should remove both add and remove operations' {
        $Global:Error.Clear()

        $result = Invoke-MergeMigration { 
            New-MigrationObject 'AddAndRemoveTable' {
                Add-Table 'snafu' {
                    int 'index' -NotNull
                }

                Remove-Table 'snafu'
            }
        }

        $Global:Error.Count | Should -Be 0

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 1

        Assert-MigrationHasNoOperations -Migration $result[0]
    }
}

Describe 'Merge-Migration.when adding columns to a table' {
    It 'should add columns to previous update operation' {

        $result = Invoke-MergeMigration {
            New-MigrationObject 'AddColumn' {
                Update-Table 'fubar' -AddColumn {
                    int 'col1'
                }
            }

            New-MigrationObject 'AddColumn2' {
                Update-Table 'fubar' -AddColumn {
                    int 'col2'
                }
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        $op = $result[0].PushOperations[0]

        $op.AddColumns.Count | Should -Be 2
        $op.AddColumns[1].Name | Should -Be 'col2'

        Assert-MigrationHasNoOperations -Migration $result[1]
    }
}

Describe 'Merge-Migration.when adding a column that was removed' {
    It 'should use the definition of the added column' {

        $result = Invoke-MergeMigration {
            New-MigrationObject 'RemoveColumns' {
                Update-Table 'fubar' -RemoveColumn 'removemeforreal','removemebymistake'
            }

            New-MigrationObject 'AddColumn' {
                Update-Table 'fubar' -AddColumn {
                    int 'removemebymistake'
                }
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        $op = $result[0].PushOperations[0]

        $op.RemoveColumns.Count | Should -Be 1
        $op.RemoveColumns[0] | Should -Be 'removemeforreal'
        $op.AddColumns.Count | Should -Be 1
        $op.AddColumns[0].Name | Should -Be 'removemebymistake'

        Assert-MigrationHasNoOperations -Migration $result[1]
    }
}

Describe 'Merge-Migration.when removing an updated column' {
    It 'should remove the column from previous update operations' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'UpdateColumn' {
                Update-Table 'fubar' -UpdateColumn {
                    int 'toberemoved'
                }
            }

            New-MigrationObject 'RemoveColumn' {
                Update-Table 'fubar' -RemoveColumn 'toberemoved'
            }

        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2
        Assert-MigrationHasNoOperations -Migration $result[0]
        Assert-MigrationHasNoOperations -Migration $result[1]
    }
}

Describe 'Merge-Migration.when removing an added column' {
    It 'should remove added column from the update operation' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'AddColumn' {
                Update-Table 'fubar' -AddColumn {
                    int 'toberemoved'
                }
            }

            New-MigrationObject 'RemoveColumn' {
                Update-Table 'fubar' -RemoveColumn 'toberemoved'
            }

        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2
        Assert-MigrationHasNoOperations -Migration $result[1]
    }
}

Describe 'Merge-Migration.when updating an added column' {
    It 'should use the new column definition in original update table operation' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'AddColumn' {
                Update-Table 'fubar' -AddColumn {
                    int 'tobeupdated'
                }
            }

            New-MigrationObject 'UpdateColumn' {
                Update-Table 'fubar' -UpdateColumn { int 'tobeupdated' -NotNull }
            }

        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        $op = $result[0].PushOperations[0]

        $op.UpdateColumns.Count | Should -Be 0
        $op.AddColumns.Count | Should -Be 1
        $op.AddColumns[0].Name | Should -Be 'tobeupdated'
        $op.AddColumns[0].NotNull | Should -BeTrue

        Assert-MigrationHasNoOperations -Migration $result[1]
    }
}

Describe 'Merge-Migration.when updating an updated column' {
    It 'should use the new column definition in original update table operation' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'UpdateColumn' {
                Update-Table 'fubar' -UpdateColumn {
                    int 'tobeupdated'
                }
            }

            New-MigrationObject 'UpdateColumn2' {
                Update-Table 'fubar' -UpdateColumn { int 'tobeupdated' -NotNull }
            }

        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2
        
        $op = $result[0].PushOperations[0]

        $op.UpdateColumns.Count | Should -Be 1
        $op.UpdateColumns[0].Name | Should -Be 'tobeupdated'
        $op.UpdateColumns[0].NotNull | Should -BeTrue

        Assert-MigrationHasNoOperations -Migration $result[1]
    }
}

Describe 'Merge-Migration.when merging multiple update table operations' {
    It 'should combine all operations into single operation' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'AddAndUpdateTable' {
                Add-Table -SchemaName 'skma' 'Farmers' {
                    int 'ID' -NotNull
                    varchar 'Name' -NotNull -Size 500
                }

                Update-Table -SchemaName 'skma' 'Farmers' -UpdateColumn {
                    varchar 'Name' -NotNull -Size 50
                } 

                Update-Table -SchemaName 'skma' 'Farmers' -AddColumn {
                    varchar 'Zip' -Size 10
                }
                Rename-Column -SchemaName 'skma' 'Farmers' -Name 'Zip' -NewName 'ZipCode'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 1
        
        $ops = $result[0].PushOperations
        $ops.Count | Should -Be 1

        $op = $ops[0]

        $op | Should -BeOfType ([Rivet.Operations.AddTableOperation])
        $op.Columns.Count | Should -Be 3
        $op.Columns[0].Name | Should -Be 'ID'
        $op.Columns[1].Name | Should -Be 'Name'
        $op.Columns[2].Name | Should -Be 'ZipCode'
    }
}

Describe 'Merge-Migration.when adding removing and adding an object' {
    It 'should remove the add and removal of the object' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'AddTable' {
                Add-Schema 'aggregate'

                Add-Table -SchemaName 'aggregate' 'Beta' {
                    int 'ID' -NotNull
                    nvarchar 'Name' -Size 50
                    nvarchar 'RemoveMe' -Size 10
                }

                Add-PrimaryKey -SchemaName 'aggregate' -TableName 'Beta' -ColumnName 'ID'
            }

            New-MigrationObject 'UpdateTable' {
                Remove-PrimaryKey -SchemaName 'aggregate' -TableName 'Beta' -Name (New-RTConstraintName -PrimaryKey -SchemaName 'aggregate' -TableName 'Beta')
                Add-PrimaryKey -SchemaName 'aggregate' -TableName 'Beta' -ColumnName 'Name'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        $ops = $result[0].PushOperations
        $ops.Count | Should -Be 2
        $ops[0] | Should -BeOfType ([Rivet.Operations.AddSchemaOperation])
        $ops[1] | Should -BeOfType ([Rivet.Operations.AddTableOperation])

        $ops = $result[1].PushOperations
        $ops.Count | Should -Be 1
        $ops[0] | Should -BeOfType ([Rivet.Operations.AddPrimaryKeyOperation])
    }
}

Describe 'Merge-Migration.when adding a column to a table then removing it' {
    It 'should remove the column' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'UpdateWithRemove' {
                Update-Table -Name 'FeedbackLog' -AddColumn {
                    varchar 'ToBeIncreased' -Size 50 -NotNull
                    varchar 'ToBeRemoved' -Size 100 -NotNull
                }

                # Yes.  Keep these separate.  That's what we're testing.
                Update-Table -Name 'FeedbackLog' -UpdateColumn { 
                    VarChar 'Feedback' -Size 3000 
                    varchar 'ToBeIncreased' -Size 200
                }

                Update-Table -Name 'FeedbackLog' -RemoveColumn 'ToBeRemoved'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 1

        $ops = $result[0].PushOperations
        $ops.Count | Should -Be 1

        $op = $ops[0]

        $op | Should -BeOfType ([Rivet.Operations.UpdateTableOperation])

        $op.AddColumns.Count | Should -Be 1
        $op.AddColumns[0].Name | Should -Be 'ToBeIncreased'
        $op.AddColumns[0].Size.ToString() | Should -Be '(200)'

        $op.UpdateColumns.Count | Should -Be 1
        $op.UpdateColumns[0].Name | Should -Be 'Feedback'

        $op.RemoveColumns.Count | Should -Be 0
    }
}

Describe 'Merge-Migration.when adding a removed column' {
    It 'should re-add the removed column' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'RemoveThenAddColumns' {
                Update-Table -Name EligibilityMaps -RemoveColumn 'UsePgpEncryption'
                Update-Table -Name EligibilityMaps -RemoveColumn 'Delimiter'
                Update-Table -Name EligibilityMaps -AddColumn { Bit 'UsePgpEncryption' -Description 'is the file expected to be encrypted?' }
                Update-Table -Name EligibilityMaps -AddColumn { char 'Delimiter' -Size 1 -Description 'what is the delimiter to use when processing the file. valid values are: [,|\t]' }
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 1

        $ops = $result[0].PushOperations

        $ops | Should -HaveCount 3

        $ops[0] | Should -BeOfType ([Rivet.Operations.UpdateTableOperation])
        $ops[0].RemoveColumns | Should -HaveCount 0
        $ops[0].UpdateColumns | Should -HaveCount 0
        $ops[0].AddColumns | Should -HaveCount 2
        $ops[0].AddColumns[0].Name | Should -Be 'UsePgpEncryption'
        $ops[0].AddColumns[1].Name | Should -Be 'Delimiter'
        $ops[1] | Should -BeOfType ([Rivet.Operations.AddExtendedPropertyOperation])
        $ops[2] | Should -BeOfType ([Rivet.Operations.AddExtendedPropertyOperation])
    }
}

Describe 'Merge-Migration.when adding removing different objects multiple times' {
    It 'should use the last added objects' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'AddPrimaryKeyAndSynonym' {
                Add-PrimaryKey -TableName 'CoachMessagingPractice_RefOnly' -ColumnName AgentId,PracticeId
                Add-Synonym -Name 'CoachMessagingPractice' -TargetDatabaseName 'hcUser' -TargetObjectName 'CoachMessagingPractice_RefOnly'
            }

            New-MigrationObject 'RemoveAndAddPrimaryKey' {
                Remove-PrimaryKey -TableName 'CoachMessagingPractice_RefOnly' -Name 'PK_CoachMessagingPractice_RefOnly'
                Add-PrimaryKey -TableName 'CoachMessagingPractice_RefOnly' -ColumnName Id
            }

            New-MigrationObject 'RemoveAndAddSynonym' {
                Remove-Synonym 'CoachMessagingPractice'
                Add-Synonym -Name 'CoachMessagingPractice' -TargetDatabaseName 'hcUser' -TargetObjectName 'CoachMessagingPractice_RefOnly'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 3

        $result[0].PushOperations.Count | Should -Be 0
        $result[1].PushOperations.Count | Should -Be 1
        $result[2].PushOperations.Count | Should -Be 1
    }
}

Describe 'Merge-Migration.when add and removal are in the same migration and there are operations after the removal' {
    It 'should leave other operations alone' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'fubar' {
                # AccountIdentityStatusHistory_RefOnly_V2
                Add-Trigger -Name 'trAccountIdentityStatusHistory_RefOnly_V2_Activity' -Definition 'fubar'
                Remove-Trigger -Name trAccountIdentityStatusHistory_RefOnly_V2_Activity
                Remove-DefaultConstraint -TableName AccountIdentityStatusHistory_RefOnly_V2 -Name DF_AccountIdentityStatusHistory_RefOnly_V2_CreateDate
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 1

        $ops = $result[0].PushOperations
        $ops.Count | Should -Be 1
        $ops[0] | Should -BeOfType ([Rivet.Operations.RemoveDefaultConstraintOperation])
    }
}

Describe 'Merge-Migration.when removing, adding, removing, then adding a primary key' {
    It 'should use the last definition of the primary key' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'removeaddone' {
                Remove-PrimaryKey -TableName 'MailingTemplate' -Name 'PK_MailingTemplate'
                Add-PrimaryKey -TableName 'MailingTemplate' -Name 'PK_MailingTemplate' -ColumnName 'MailingTemplateID','SponsorID'
            }
            New-MigrationObject 'removeaddtwo' {
                Remove-PrimaryKey -TableName 'MailingTemplate' -Name 'PK_MailingTemplate'
                Add-PrimaryKey -TableName 'MailingTemplate' -Name 'PK_MailingTemplate' -ColumnName 'MailingTemplateID'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        $ops = $result[0].PushOperations
        $ops | Should -HaveCount 1
        $ops | Should -BeOfType ([Rivet.Operations.RemovePrimaryKeyOperation])

        $ops = $result[1].PushOperations
        $ops | Should -HaveCount 1
        $ops | Should -BeOfType ([Rivet.Operations.AddPrimaryKeyOperation])
        $ops.ColumnName | Should -HaveCount 1
        $ops.ColumnName | Should -Be 'MailingTemplateID'
    }
}

Describe 'Merge-Migration.when objects across databases have the same name' {
    It 'should ignore operations across databases' {
        $result = Invoke-MergeMigration {

            New-MigrationObject 'synonyms' -DatabaseName 'Messaging' {
                Add-Synonym -Name 'Task' -SchemaName 'dshbrd' -TargetDatabaseName 'Logging' -TargetSchemaName 'dshbrd' -TargetObjectName 'Task'
                Add-Synonym -Name 'TaskDetail' -SchemaName 'dshbrd' -TargetDatabaseName 'Logging' -TargetSchemaName 'dshbrd' -TargetObjectName 'TaskDetail'
                Add-Synonym -Name 'ExclusiveProcess' -SchemaName 'dshbrd' -TargetDatabaseName 'Admin' -TargetSchemaName 'dshbrd' -TargetObjectName 'ExclusiveProcess'
                Add-Synonym -Name 'ExclusiveProcessType' -SchemaName 'dshbrd' -TargetDatabaseName 'Admin' -TargetSchemaName 'dshbrd' -TargetObjectName 'ExclusiveProcessType'
            }

            New-MigrationObject 'synonyms' -DatabaseName 'PlatformLogging' {
                Add-View -Name 'Task' -SchemaName 'dshbrd' -Definition ' AS SELECT * FROM dbo.Task'
                Add-View -Name 'TaskDetail' -SchemaName 'dshbrd' -Definition ' AS SELECT * FROM dbo.TaskDetail'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        $ops = $result[0].PushOperations
        $ops.Count | Should -Be 4
        $ops = $result[1].PushOperations
        $ops.Count | Should -Be 2
    }
}

Describe 'Merge-Migration.when removing a table with keys, indexes, and constraints' {
    It 'should remove all the dependent objects' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'addremovetable' {
                Add-Table 'table' -Description 'table desc' {
                    int 'ID' -NotNull -Description 'column desc'
                }

                Add-PrimaryKey 'table' 'ID'
                Add-Index 'table' -ColumnName 'ID'
                Add-RowGuidCol 'table' 'ID'
                Disable-Constraint 'table' 'disabled_constraint'
                Enable-Constraint 'table' 'enabled_constraint'
                Add-CheckConstraint 'table' 'check_constraint' 'expression'
                Add-DefaultConstraint 'table' 'ID' 'expression'
                Add-ForeignKey 'table' 'ID' 'other_table' 'other_column'
                Add-UniqueKey 'table' 'ID'

                Remove-Table 'table'

                Add-Table 'table' {
                    int 'ID2' -NotNull
                }

                Add-PrimaryKey 'table' 'ID2'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 1

        $ops = $result[0].PushOperations

        $ops.Count | Should -Be 2

        $ops[0] | Should -BeOfType ([Rivet.Operations.AddTableOperation])
        $ops[0].Columns.Count | Should -Be 1
        $ops[0].Columns[0].Name | Should -Be 'ID2'
        $ops[1] | Should -BeOfType ([Rivet.Operations.AddPrimaryKeyOperation])
        $ops[1].ColumnName.Count | Should -Be 1
        $ops[1].ColumnName[0] | Should -Be 'ID2'
    }
}

Describe 'Merge-Migration.when removing and re-adding the same table across migrations' {
    It 'should use latest definition' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'blah1' {
                Add-Table -Name 'admTestUser' {
                    Bit 'Active' -NotNull -Default '1'
                }
        
                Add-PrimaryKey -TableName 'admTestUser' -ColumnName 'TestUserID'
            }

            New-MigrationObject 'blah' {
                Remove-Table -Name 'admTestUser'
        
                Add-Table -Name 'admTestUser' {
                    Bit 'Active2' -NotNull -Default '1'
                }
        
                Add-PrimaryKey -TableName 'admTestUser' -ColumnName 'TestUserID2'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2

        Assert-MigrationHasNoOperations $result[0]

        $ops = $result[1].PushOperations

        $ops.Count | Should -Be 2
        $ops[0].Columns.Count | Should -Be 1
        $ops[0].Columns[0].Name | Should -Be 'Active2'
        $ops[1].ColumnName.Count | Should -Be 1
        $ops[1].ColumnName[0] | Should -Be 'TestUserID2'
    }
}

Describe 'Merge-Migration.when table and column have same name and the table is renamed' {
    It 'should not fail' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'one' {
                Add-Table -Name 'OldName' {
                    int 'id'
                }
            }
            New-MigrationObject 'two' {
                Update-Table 'OldName' -AddColumn {
                    tinyint 'OldColumn' -NotNull
                }
            }
            New-MigrationObject 'three' {
                Rename-Object -Name 'OldName' -NewName 'NewName'
            }
            New-MigrationObject 'four' {
                Add-Table -Name 'OldColumn' {
                    tinyint 'OldColumnId' -NotNull
                }
            }
            New-MigrationObject 'five' {
                Rename-Column -TableName 'NewName' -Name 'OldColumn' -NewName 'OldColumnId'
            }
        }
        $result | Should -Not -BeNullOrEmpty
    }
}

Describe 'Merge-Migration.when adding/removing rowguildcol from columns' {
    It ('should merge rowguidcol into AddTable') {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'migration' {
                Add-Table 'AddInThisMigration' {
                    uniqueidentifier 'add_rowguidcol'
                }
                Add-Table 'RemoveInThisMigration' {
                    uniqueidentifier 'remove_rowguidcol' -RowGuidCol
                }
            }
            New-MigrationObject 'migration2' {
                Add-RowGuidCol -TableName 'AddInThisMigration' -ColumnName 'add_rowguidcol'

                Remove-RowGuidCol -TableName 'RemoveInThisMigration' -ColumnName 'remove_rowguidcol'

                Add-RowGuidCol -TableName 'AddMyRowGuidCol' -ColumnName  'future_rowguidcol'
                Remove-RowGuidCol -TableName 'RemoveMyRowGuidCol' -ColumnName 'bye_bye_rowguidcol'
            }
        }

        Assert-AllMigrationsReturned -MergedMigration $result -ExpectedCount 2
        $ops = $result.PushOperations
        $ops.Count | Should -Be 4
        $ops[0] | Should -BeOfType ([Rivet.Operations.AddTableOperation])
        ([Rivet.Operations.AddTableOperation]$ops[0]).Columns[0].RowGuidCol | Should -BeTrue

        $ops[1] | Should -BeOfType ([Rivet.Operations.AddTableOperation])
        ([Rivet.Operations.AddTableOperation]$ops[1]).Columns[0].RowGuidCol | Should -BeFalse

        $ops[2] | Should -BeOfType ([Rivet.Operations.AddRowGuidColOperation])
        $ops[3] | Should -BeOfType ([Rivet.Operations.RemoveRowGuidColOperation])
    }
}

Describe 'Merge-Migration.when objects have extended properties' {
    It 'should remove the extended properties' {
        $result = Invoke-MergeMigration {
            New-MigrationObject 'one' {
                Add-Table -Name 'with_description' -Description 'TABLE' {
                    int 'id' -Description 'COLUMN'
                }

                Add-Schema -Name 'with_description'
                Add-ExtendedProperty -Name ([Rivet.Operations.ExtendedPropertyOperation]::DescriptionPropertyName) -Value 'SCHEMA' -SchemaName 'with_description'

                Add-View -Name 'with_description' -Definition @'
as 
    select 1 One
'@
                Add-ExtendedProperty -Name ([Rivet.Operations.ExtendedPropertyOperation]::DescriptionPropertyName) -Value 'VIEW' -ViewName 'with_description'
                Add-ExtendedProperty -Name ([Rivet.Operations.ExtendedPropertyOperation]::DescriptionPropertyName) -Value 'VIEW-COLUMN' -ViewName 'with_description' -ColumnName 'One'
            }

            New-MigrationObject 'two' {
                Remove-View -Name 'with_description'
                Remove-Schema -Name 'with_description'
                Remove-Table -Name 'with_description'
            }
        }

        $result | Should -HaveCount 2
        $result[0].PushOperations | Should -HaveCount 0
        $result[1].PushOperations | Should -HaveCount 0
    }
}
