
& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'Update-CodeObjectMetadata' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Invoke-RTRivet -Pop -All
        Stop-RivetTest
    }
    
    It 'should update metadata' {
        @'
    function Push-Migration
    {
        Add-Schema 'refresh'
    
        Add-DataType -SchemaName 'refresh' -Name 'mytype' -From 'nvarchar(5)'
    
        Add-UserDefinedFunction -SchemaName 'refresh' -Name 'to_upper' -Definition @"
    (@a mytype)
    RETURNS mytype
    WITH ENCRYPTION
    AS
    BEGIN
    RETURN upper(@a)
    END
"@
    }
    
    function Pop-Migration
    {
        Remove-UserDefinedFunction -SchemaName 'refresh' 'to_upper'
        Remove-DataType -SchemaName 'refresh' 'mytype'
        Remove-Schema 'refresh'
    }
'@ | New-TestMigration -Name 'CreateToUpper'
    
        Invoke-RTRivet -Push
    
        $query = 'select refresh.to_upper(''abcdefgh'') Result'
        $result = Invoke-RivetTestQuery -Query $query -AsScalar
        ($result -ceq 'ABCDE') | Should -BeTrue
    
        @'
    function Push-Migration
    {
        Rename-DataType -SchemaName 'refresh' -Name 'mytype' -NewName 'myoldtype'
        Add-DataType -SchemaName 'refresh' -Name 'mytype' -From 'nvarchar(10)'
        Update-CodeObjectMetadata -SchemaName 'refresh' -Name 'to_upper'
    }
    
    function Pop-Migration
    {
        Rename-DataType -SchemaName 'refresh' -Name 'mytype' -NewName 'mytype_REMOVE'
        Rename-DataType -SchemaName 'refresh' -Name 'myoldtype' -NewName 'mytype'
        Update-CodeObjectMetadata -SchemaName 'refresh' -Name 'to_upper'
        Remove-DataType -SchemaName 'refresh' -Name 'mytype_REMOVE'
    }
'@ | New-TestMigration -Name 'IncreaseToUpperLength'
    
        Invoke-RTRivet -Push
    
        $result = Invoke-RivetTestQuery -Query $query -AsScalar
        ($result -ceq 'ABCDEFGH') | Should -BeTrue
    }
}
