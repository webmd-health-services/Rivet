
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
    @'
function Push-Migration()
{
    Add-Table -Name 'RemoveUniqueKey' {
        Int 'RemoveMyUniqueKey' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey'

    #Remove Index
    Remove-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey'
}

function Pop-Migration()
{
    Remove-Table 'RemoveUniqueKey'
}
'@ | New-Migration -Name 'RemoveUniqueKey'
    Invoke-Rivet -Push 'RemoveUniqueKey'
    Assert-False (Test-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey')

}

function Test-ShouldRemoveUniqueKey
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Remove-UniqueKey' {
        Int 'RemoveMyUniqueKey' -NotNull
    }

    Add-UniqueKey -TableName 'Remove-UniqueKey' -ColumnName 'RemoveMyUniqueKey'
    Remove-UniqueKey -TableName 'Remove-UniqueKey' -ColumnName 'RemoveMyUniqueKey'
}

function Pop-Migration()
{
    Remove-Table 'Remove-UniqueKey'
}
'@ | New-Migration -Name 'RemoveUniqueKey'
    Invoke-Rivet -Push 'RemoveUniqueKey'
    Assert-False (Test-UniqueKey -TableName 'Remove-UniqueKey' -ColumnName 'RemoveMyUniqueKey')

}

function Test-ShouldRemoveUniqueKeyWithCustomName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Add-UniqueKey' {
        Int 'UniqueKeyMe' -NotNull
    }

    Add-UniqueKey -TableName 'Add-UniqueKey' -ColumnName 'UniqueKeyMe' -Name 'Custom'
    Remove-UniqueKey -TableName 'Add-UniqueKey' -Name 'Custom'
}

function Pop-Migration()
{
    Remove-Table 'Add-UniqueKey'
}
'@ | New-Migration -Name 'AddUniqueKeyWithCustomName'
    Invoke-Rivet -Push 'AddUniqueKeyWithCustomName'
    
    $UQC = Invoke-RivetTestQuery -Query "select * from sys.indexes where is_unique_constraint='True'"

    Assert-Null $UQC

}