
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

Describe 'Add-Description' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should add table and column description' {
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
    }
'@ | New-TestMigration -Name 'AddDescription'
        Invoke-RTRivet -Push 'AddDescription'
    
        Assert-Table -Name 'MS_Description' -Description 'new description' 
        Assert-Column -Name 'add_description' 'varchar' -Description 'new description' -TableName 'MS_Description'
    }
}
