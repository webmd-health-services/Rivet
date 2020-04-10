
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'Remove-ForeignKey' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest -Pop
    }
    
    It 'should remove foreign key' {
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
        Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id'
        Remove-ForeignKey 'Source' -Name '$(New-RTConstraintName -ForeignKey 'Source' 'Reference')'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'Reference'
        Remove-Table 'Source'
    }
"@ | New-TestMigration -Name 'RemoveForeignKey'
        Invoke-RTRivet -Push "RemoveForeignKey"
        (Test-ForeignKey -TableName 'Source' -References 'Reference') | Should -BeFalse
    }
    
    It 'should quote foreign key name' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Remove-ForeignKey' {
            Int 'source_id' -NotNull
        }
    
        Add-Table -Name 'Reference' {
            Int 'reference_id' -NotNull
        }
    
        Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
        Add-ForeignKey -TableName 'Remove-ForeignKey' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id'
        Remove-ForeignKey -TableName 'Remove-ForeignKey' -Name '$(New-RTConstraintName -ForeignKey 'Remove-ForeignKey' 'Reference')'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'Reference'
        Remove-Table 'Remove-ForeignKey'
    }
"@ | New-TestMigration -Name 'RemoveForeignKey'
        Invoke-RTRivet -Push "RemoveForeignKey"
        (Test-ForeignKey -TableName 'Remove-ForeignKey' -References 'Reference') | Should -BeFalse
    }
    
    It 'should remove foreign key using default key name' {
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
        Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id'
        Remove-ForeignKey 'Source' 'Reference'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'Reference'
        Remove-Table 'Source'
    }
"@ | New-TestMigration -Name 'RemoveForeignKey'
        Invoke-RTRivet -Push "RemoveForeignKey"
        (Test-ForeignKey -TableName 'Source' -References 'Reference') | Should -BeFalse
    }
    
}
