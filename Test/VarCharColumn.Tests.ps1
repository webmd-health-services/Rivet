
Set-StrictMode -Version 'Latest'
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

Describe 'VarCharColumn' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should create var char column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            VarChar 'id' -Max
        } -Option 'data_compression = none'
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateVarCharColumn'
    
        Invoke-RTRivet -Push 'CreateVarCharColumn'
        
        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -Max
    }
    
    It 'should create var char column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            VarChar 'id' -Max -Sparse
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateVarCharColumnWithSparse'
    
        Invoke-RTRivet -Push 'CreateVarCharColumnWithSparse'
        
        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -Sparse -Max
    }
    
    It 'should create var char column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            VarChar 'id' -Max -NotNull
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateVarCharColumnWithNotNull'
    
        Invoke-RTRivet -Push 'CreateVarCharColumnWithNotNull'
        
        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -NotNull -Max
    }
    
    It 'should create var char column with custom size collation' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            VarChar 'id' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'ShouldCreateVarCharColumnWithCustomSizeCollation'
    
        Invoke-RTRivet -Push 'ShouldCreateVarCharColumnWithCustomSizeCollation'
        
        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
    }
}
