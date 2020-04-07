
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

Describe 'New-VarBinaryColumn' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should create var binary column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            VarBinary 'id' -Max
        } -Option 'data_compression = none'
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateVarBinaryColumn'
    
        Invoke-RTRivet -Push 'CreateVarBinaryColumn'
        
        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -Max
    }
    
    # This test won't work unless file streams are setup.  Don't know how to do that so ignoring this test for now.
    It -Skip 'should create var binary column with file stream' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            VarBinary 'id' -Max -FileStream "default"
        } -FileStreamFileGroup "default"
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateVarBinaryColumnWithFileStream'
    
        Invoke-RTRivet -Push 'CreateVarBinaryColumnWithFileStream'
        
        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -Max
    }
    
    It 'should create var binary column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            VarBinary 'id' -Max -NotNull
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateVarBinaryColumnWithNotNull'
    
        Invoke-RTRivet -Push 'CreateVarBinaryColumnWithNotNull'
        
        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -NotNull -Max
    }
    
    It 'should create var binary column with custom size' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            VarBinary 'id' 50 -NotNull
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'ShouldCreateVarBinaryColumnWithCustomSize'
    
        Invoke-RTRivet -Push 'ShouldCreateVarBinaryColumnWithCustomSize'
        
        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -NotNull -Size 50 
    }
}
