
function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RenameDataType' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldUpdateMetadata
{
    @'
function Push-Migration
{
    Add-Schema 'refresh'

    Add-DataType -SchemaName 'refresh' -Name 'mytype' -From 'nvarchar(5)'
}
'@ | New-Migration -Name 'CreateMyType'

    Invoke-Rivet -Push

    Assert-DataType -SchemaName 'refresh' -Name 'mytype' -BaseType 'nvarchar' -UserDefined

    @'
function Push-Migration
{
    Rename-DataType -SchemaName 'refresh' -Name 'mytype' -NewName 'myoldtype'
}
'@ | New-Migration -Name 'IncreaseToUpperLength'

    Invoke-Rivet -Push

    Assert-DataType -SchemaName 'refresh' -Name 'myoldtype' -BaseType 'nvarchar' -UserDefined
}