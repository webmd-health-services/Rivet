
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

Describe 'Remove-Description' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should remove table and column description' {
        @'
    function Push-Migration()
    {
        Add-Table 'MS_Description' -Column {
            varchar add_description -Max 
        }
    
        Add-Description -Description 'new description' -TableName 'MS_Description'
        Add-Description -Description 'new description' -TableName 'MS_Description' -ColumnName 'add_description'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'MS_Description'
    }
'@ | New-TestMigration -Name 'AddDescription'
    
        Invoke-RTRivet -Push 'AddDescription'
    
        Assert-Table -Name 'MS_Description' -Description 'new description'
        Assert-Column -Name 'add_description' 'varchar' -Description 'new description' -TableName MS_Description
    
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
    
        @'
    function Push-Migration()
    {
        Remove-Description -TableName MS_Description 
        Remove-Description -TableName MS_Description -ColumnName 'add_description'
    }
    
    function Pop-Migration()
    {
        Add-Description -Description 'updated description' -TableName MS_Description
        Add-Description -Description 'updated description' -TableName MS_Description -ColumnName 'add_description'
    }
'@ | New-TestMigration -Name 'RemoveDescription'
    
        Invoke-RTRivet -Push 'RemoveDescription'
        Assert-Table -Name 'MS_Description' -Description $null 
        Assert-Column -Name 'add_description' 'varchar' -Description $null -TableName MS_Description
    }
}
