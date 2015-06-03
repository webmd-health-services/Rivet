
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldUpdateMetadata
{
    @'
function Push-Migration
{
    Add-Schema 'refresh'

    Add-DataType -SchemaName 'refresh' -Name 'mytype' -From 'nvarchar(5)'
}

function Pop-Migration
{
    Remove-DataType -SchemaName 'refresh' -Name 'mytype'
    Remove-Schema 'refresh'
}
'@ | New-Migration -Name 'CreateMyType'

    Invoke-RTRivet -Push

    Assert-DataType -SchemaName 'refresh' -Name 'mytype' -BaseType 'nvarchar' -UserDefined

    @'
function Push-Migration
{
    Rename-DataType -SchemaName 'refresh' -Name 'mytype' -NewName 'myoldtype'
}

function Pop-Migration
{
    Rename-DataType -SchemaName 'refresh' -Name 'myoldtype' -NewName 'mytype'
}
'@ | New-Migration -Name 'IncreaseToUpperLength'

    Invoke-RTRivet -Push

    Assert-DataType -SchemaName 'refresh' -Name 'myoldtype' -BaseType 'nvarchar' -UserDefined
}
