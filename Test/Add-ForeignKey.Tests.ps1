
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'Add-ForeignKey' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest -Pop
    }
    
    It 'should add foreign key from single column to single column' {
        @"
    function Push-Migration()
    {
        # Yes.  Spaces in the name so we check the name gets quoted.
        Add-Table -Name 'Source Table' {
            Int 'Source ID' -NotNull
        }
    
        Add-Table -Name 'Reference Table' {
            Int 'Reference ID' -NotNull
        }
    
        Add-PrimaryKey -TableName 'Reference Table' -ColumnName 'Reference ID'
        Add-ForeignKey 'Source Table' 'Source ID' 'Reference Table' 'Reference ID'
    }
    
    function Pop-Migration()
    {
        Remove-ForeignKey 'Source Table' -Name '$(New-ForeignKeyConstraintName 'Source Table' 'REference Table')'
        Remove-Table 'Reference Table'
        Remove-Table 'Source Table'
    }
"@ | New-TestMigration -Name 'AddForeignKeyFromSingleColumnToSingleColumn'
        Invoke-RTRivet -Push 'AddForeignKeyFromSingleColumnToSingleColumn'
        Assert-ForeignKey -TableName 'Source Table' -References 'Reference Table'
    }
    
    It 'should add foreign key from multiple column to multiple column' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Source' {
            Int 's_id_1' -NotNull
            Int 's_id_2' -NotNull
        }
    
        Add-Table -Name 'Reference' {
            Int 'r_id_1' -NotNull
            Int 'r_id_2' -NotNull
        }
    
        Add-PrimaryKey -TableName 'Reference' -ColumnName 'r_id_1','r_id_2'
        Add-ForeignKey -TableName 'Source' -ColumnName 's_id_1','s_id_2' -References 'Reference' -ReferencedColumn 'r_id_1','r_id_2'
    }
    
    function Pop-Migration()
    {
        Remove-ForeignKey 'Source' -Name '$(New-ForeignKeyConstraintName 'Source' 'Reference')'
        Remove-Table 'Reference'
        Remove-Table 'Source'
    }
"@ | New-TestMigration -Name 'AddForeignKeyFromMultipleColumnToMultipleColumn'
        Invoke-RTRivet -Push 'AddForeignKeyFromMultipleColumnToMultipleColumn'
        Assert-ForeignKey -TableName 'Source' -References 'Reference'
    }
    
    It 'should add foreign key with custom schema' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Source' -SchemaName 'rivet' {
            Int 'source_id' -NotNull
        }
    
        Add-Table -Name 'Reference' -SchemaName 'rivet' {
            Int 'reference_id' -NotNull
        }
    
        Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id' -SchemaName 'rivet'
        Add-ForeignKey -TableName 'Source' -SchemaName 'rivet' -ColumnName 'source_id' -References 'Reference' -ReferencesSchema 'rivet' -ReferencedColumn 'reference_id'
    }
    
    function Pop-Migration()
    {
        Remove-ForeignKey 'Source' -SchemaName 'rivet' -Name '$(New-ForeignKeyConstraintName -SourceSchema 'rivet' 'Source' -TargetSchema 'rivet' 'Reference')'
        Remove-Table 'Reference' -SchemaName 'rivet'
        Remove-Table 'Source' -SchemaName 'rivet'
    }
"@ | New-TestMigration -Name 'AddForeignKeyWithCustomSchema'
        Invoke-RTRivet -Push 'AddForeignKeyWithCustomSchema'
        Assert-ForeignKey -TableName 'Source' -SchemaName 'rivet' -References 'Reference' -ReferencesSchema 'rivet'
    }
    
    It 'should add foreign key with on delete' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Source' {
            Int 'source_id' -NotNull
        }
    
        Add-Table -Name 'Reference' {
            Int 'reference_id' -NotNull
        }
    
        Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
        Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id' -OnDelete 'CASCADE'
    }
    
    function Pop-Migration()
    {
        Remove-ForeignKey 'Source' -Name '$(New-ForeignKeyConstraintName 'Source' 'Reference')'
        Remove-Table 'Reference'
        Remove-Table 'Source'
    }
"@ | New-TestMigration -Name 'AddForeignKeyWithOnDelete'
        Invoke-RTRivet -Push 'AddForeignKeyWithOnDelete'
        Assert-ForeignKey -TableName 'Source' -References 'Reference' -OnDelete 'CASCADE'
    
    }
    
    It 'should add foreign key with on update' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Source' {
            Int 'source_id' -NotNull
        }
    
        Add-Table -Name 'Reference' {
            Int 'reference_id' -NotNull
        }
    
        Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
        Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id' -OnDelete 'CASCADE' -OnUpdate 'CASCADE'
    }
    
    function Pop-Migration()
    {
        Remove-ForeignKey 'Source' -Name '$(New-ForeignKeyConstraintName 'Source' 'Reference')'
        Remove-Table 'Reference'
        Remove-Table 'Source'
    }
"@ | New-TestMigration -Name 'AddForeignKeyWithOnUpdate'
        Invoke-RTRivet -Push 'AddForeignKeyWithOnUpdate'
        Assert-ForeignKey -TableName 'Source' -References 'Reference' -OnDelete 'CASCADE' -OnUpdate 'CASCADE'
    }
    
    It 'should add foreign key not for replication' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Source' {
            Int 'source_id' -NotNull
        }
    
        Add-Table -Name 'Reference' {
            Int 'reference_id' -NotNull
        }
    
        Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
        Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication
    }
    
    function Pop-Migration()
    {
        Remove-ForeignKey 'Source' -Name '$(New-ForeignKeyConstraintName 'Source' 'Reference')'
        Remove-Table 'Reference'
        Remove-Table 'Source'
    }
"@ | New-TestMigration -Name 'AddForeignKeyNotForReplication'
        Invoke-RTRivet -Push 'AddForeignKeyNotForReplication'
        Assert-ForeignKey -TableName 'Source' -References 'Reference' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication
    
    }
    
    It 'should quote foreign key name' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Add-ForeignKey' {
            Int 'source_id' -NotNull
        }
    
        Add-Table -Name 'Reference' {
            Int 'reference_id' -NotNull
        }
    
        Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
        Add-ForeignKey -TableName 'Add-ForeignKey' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id'
    }
    
    function Pop-Migration()
    {
        Remove-ForeignKey 'Add-ForeignKey' -Name '$(New-ForeignKeyConstraintName 'Add-ForeignKey' 'Reference')'
        Remove-Table 'Reference'
        Remove-Table 'Add-ForeignKey'
    }
"@ | New-TestMigration -Name 'AddForeignKeyFromSingleColumnToSingleColumn'
        Invoke-RTRivet -Push 'AddForeignKeyFromSingleColumnToSingleColumn'
        Assert-ForeignKey -TableName 'Add-ForeignKey' -References 'Reference'
    }
    
    It 'should add foreign key with no check' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Source Table' {
            Int 'Source ID' -NotNull
        }
    
        Add-Table -Name 'Reference Table' {
            Int 'Reference ID' -NotNull
        }
    
        Add-Row 'Source Table' @( @{ 'Source ID' = 1 } )
        Add-Row 'Reference Table' @( @{ 'Reference ID' = 2 } )
    
        Add-PrimaryKey -TableName 'Reference Table' -ColumnName 'Reference ID'
    
        # Will fail without NOCHECK constraint
        Add-ForeignKey 'Source Table' 'Source ID' 'Reference Table' 'Reference ID' -NoCheck
    }
    
    function Pop-Migration()
    {
        Remove-ForeignKey 'Source Table' -Name '$(New-ForeignKeyConstraintName 'Source Table' 'Reference Table')'
        Remove-Table 'Reference Table'
        Remove-Table 'Source Table'
    }
"@ | New-TestMigration -Name 'AddForeignKeyFromSingleColumnToSingleColumn'
        Invoke-RTRivet -Push 'AddForeignKeyFromSingleColumnToSingleColumn'
    
        $SourceRow = Get-Row -SchemaName 'dbo' -TableName 'Source Table'
        $SourceRow.'Source ID' | Should -Be 1
    
        $ReferenceRow = Get-Row -SchemaName 'dbo' -TableName 'Reference Table'
        $ReferenceRow.'Reference ID' | Should -Be 2
    
        Assert-ForeignKey -TableName 'Source Table' -References 'Reference Table'
    }
}
