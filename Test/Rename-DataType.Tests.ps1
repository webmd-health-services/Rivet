
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

Describe 'Rename-DataType' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should update metadata' {
        @'
    function Push-Migration
    {
        Add-Schema 'refresh.part2'
    
        Add-DataType -SchemaName 'refresh.part2' -Name 'my.type' -From 'nvarchar(5)'
    }
    
    function Pop-Migration
    {
        Remove-DataType -SchemaName 'refresh.part2' -Name 'my.type'
        Remove-Schema 'refresh.part2'
    }
'@ | New-TestMigration -Name 'CreateMyType'
    
        Invoke-RTRivet -Push
    
        Assert-DataType -SchemaName 'refresh.part2' -Name 'my.type' -BaseType 'nvarchar' -UserDefined
    
        @'
    function Push-Migration
    {
        Rename-DataType -SchemaName 'refresh.part2' -Name 'my.type' -NewName 'myoldtype'
    }
    
    function Pop-Migration
    {
        Rename-DataType -SchemaName 'refresh.part2' -Name 'myoldtype' -NewName 'my.type'
    }
'@ | New-TestMigration -Name 'IncreaseToUpperLength'
    
        Invoke-RTRivet -Push
    
        Assert-DataType -SchemaName 'refresh.part2' -Name 'myoldtype' -BaseType 'nvarchar' -UserDefined
    }
}
