
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Rename-DataType' {
    BeforeEach { Start-RivetTest }
    AfterEach { Stop-RivetTest }

    It 'updates metadata' {
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

    It 'creates idempotent query' {
        GivenMigration -Named 'CreateMyBigIntType' -InputObject @'
function Push-Migration
{
    Add-DataType -Name 'MyInt' -From 'bigint'
}
function Pop-Migration
{
    Remove-DataType -Name 'MyInt'
}
'@
        WhenMigrating -Push
        Assert-DataType -Name 'MyInt' -BaseType 'bigint' -UserDefined

        $op = Rename-DataType -Name 'MyInt' -NewName 'MyBigInt'
        try
        {
            # Run twice to make sure it is really idempotent
            Invoke-RivetTestQuery -Query $op.ToIdempotentQuery()
            Invoke-RivetTestQuery -Query $op.ToIdempotentQuery()
            Assert-DataType -Name 'MyBigInt' -BaseType 'bigint' -UserDefined
        }
        finally
        {
            $op = Rename-DataType -Name 'MyBigInt' -NewName 'MyInt'
            Invoke-RivetTestQuery -Query $op.ToIdempotentQuery()
            Invoke-RivetTestQuery -Query $op.ToIdempotentQuery()
        }
    }
}

