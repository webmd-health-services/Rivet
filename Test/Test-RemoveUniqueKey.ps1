
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveUniqueKey
{
    @"
function Push-Migration()
{
    Add-Table -Name 'RemoveUniqueKey' {
        Int 'RemoveMyUniqueKey' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey'

    #Remove Index
    Remove-UniqueKey -TableName 'RemoveUniqueKey' -Name '$(New-ConstraintName -UniqueKey 'RemoveUniqueKey' 'RemoveMyUniqueKey')'
}

function Pop-Migration()
{
    Remove-Table 'RemoveUniqueKey'
}
"@ | New-Migration -Name 'RemoveUniqueKey'
    Invoke-RTRivet -Push 'RemoveUniqueKey'
    Assert-False (Test-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey')

}

function Test-ShouldRemoveUniqueKey
{
    @"
function Push-Migration()
{
    Add-Table -Name 'Remove-UniqueKey' {
        Int 'RemoveMyUniqueKey' -NotNull
    }

    Add-UniqueKey -TableName 'Remove-UniqueKey' -ColumnName 'RemoveMyUniqueKey'
    Remove-UniqueKey -TableName 'Remove-UniqueKey' -Name '$(New-ConstraintName -UniqueKey 'Remove-UniqueKey' 'RemoveMyUniqueKey')'
}

function Pop-Migration()
{
    Remove-Table 'Remove-UniqueKey'
}
"@ | New-Migration -Name 'RemoveUniqueKey'
    Invoke-RTRivet -Push 'RemoveUniqueKey'
    Assert-False (Test-UniqueKey -TableName 'Remove-UniqueKey' -ColumnName 'RemoveMyUniqueKey')

}
