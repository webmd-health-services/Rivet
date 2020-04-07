
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) 

Describe 'Update-Description' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should update table and column description' {
        @'
    function Push-Migration()
    {
        Add-Table 'MS_Description' -Column {
            varchar 'add_description' -Max
        }
    
        Add-Description -Description 'new description' -TableName 'MS_Description'
        Add-Description -Description 'new description' -TableName 'MS_Description' -ColumnName 'add_description'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'MS_Description'
    }4
'@ | New-TestMigration -Name 'AddDescription'
        Invoke-RTRivet -Push 'AddDescription'
    
        @'
    function Push-Migration()
    {
        Update-Description -Description 'updated description' -TableName MS_Description
        Update-Description -Description 'updated description' -TableName MS_Description -ColumnName 'add_description'
    }
    
    function Pop-Migration()
    {
        Update-Description -Description 'new description' -TableName MS_Description
        Update-Description -Description 'new description' -TableName MS_Description -ColumnName 'add_description'
    }
'@ | New-TestMigration -Name 'UpdateDescription'
        Invoke-RTRivet -Push 'UpdateDescription'
    
        Assert-Table -Name 'MS_Description' -Description 'updated description' 
        Assert-Column -Name 'add_description' 'varchar' -Description 'updated description' -TableName MS_Description
    }
}
