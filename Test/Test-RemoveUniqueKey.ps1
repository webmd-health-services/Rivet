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
}
'@ | New-Migration -Name 'RemoveUniqueKey'
    Invoke-Rivet -Push 'RemoveUniqueKey'
    Assert-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey' -TestNoUnique

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
}
'@ | New-Migration -Name 'RemoveUniqueKey'
    Invoke-Rivet -Push 'RemoveUniqueKey'
    Assert-UniqueKey -TableName 'Remove-UniqueKey' -ColumnName 'RemoveMyUniqueKey' -TestNoUnique

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
}
'@ | New-Migration -Name 'AddUniqueKeyWithCustomName'
    Invoke-Rivet -Push 'AddUniqueKeyWithCustomName'
    
    $UQC = Invoke-RivetTestQuery -Query "select * from sys.indexes where is_unique_constraint='True'"

    Assert-Null $UQC

}