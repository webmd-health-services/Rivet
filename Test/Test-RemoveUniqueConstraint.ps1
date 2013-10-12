function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRemoveUniqueConstraint
{
    @'
function Push-Migration()
{
    Add-Table -Name 'RemoveUniqueConstraint' {
        Int 'RemoveMyUniqueConstraint' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-UniqueConstraint -TableName 'RemoveUniqueConstraint' -ColumnName 'RemoveMyUniqueConstraint'

    #Remove Index
    Remove-UniqueConstraint -TableName 'RemoveUniqueConstraint' -ColumnName 'RemoveMyUniqueConstraint'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'RemoveUniqueConstraint'
    Invoke-Rivet -Push 'RemoveUniqueConstraint'
    Assert-UniqueConstraint -TableName 'RemoveUniqueConstraint' -ColumnName 'RemoveMyUniqueConstraint' -TestNoUnique

}