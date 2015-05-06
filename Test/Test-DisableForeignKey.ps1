function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldDisableForeignKey
{
    @'
function Push-Migration()
{
    Add-Table 'SourceTable' -Column {
        Int 'SourceID' -NotNull
    }

    Add-Table 'ReferenceTable' -Column {
        Int 'ReferenceID' -NotNull
    }

    Add-PrimaryKey -TableName 'ReferenceTable' -ColumnName 'ReferenceID'
    Add-ForeignKey 'SourceTable' 'SourceID' 'ReferenceTable' 'ReferenceID'

    Disable-ForeignKey 'SourceTable' 'SourceID' 'ReferenceTable'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'DisabledForeignKey'

    Invoke-Rivet -Push 'DisabledForeignKey'
    Assert-ForeignKey -TableName 'SourceTable' -References 'ReferenceTable' -IsDisabled
}

function Test-ShouldDisableForeignKeyWithMultipleColumns
{
    @'
function Push-Migration()
{
    Add-Table 'SourceTable' -Column {
        Int 'SourceID1' -NotNull
        Int 'SourceID2' -NotNull
    }

    Add-Table 'ReferenceTable' -Column {
        Int 'ReferenceID1' -NotNull
        Int 'ReferenceID2' -NotNull
    }

    Add-PrimaryKey -TableName 'ReferenceTable' -ColumnName 'ReferenceID1','ReferenceID2'
    Add-ForeignKey 'SourceTable' 'SourceID1','SourceID2' 'ReferenceTable' 'ReferenceID1','ReferenceID2'

    Disable-ForeignKey 'SourceTable' 'SourceID1','SourceID2' 'ReferenceTable'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'DisabledForeignKey'

    Invoke-Rivet -Push 'DisabledForeignKey'
    Assert-ForeignKey -TableName 'SourceTable' -References 'ReferenceTable' -IsDisabled
}


function Test-ShouldDisableForeignKeyWithName
{
    @'
function Push-Migration()
{
    Add-Table 'SourceTable' -Column {
        Int 'SourceID' -NotNull
    }

    Add-Table 'ReferenceTable' -Column {
        Int 'ReferenceID' -NotNull
    }

    Add-PrimaryKey -TableName 'ReferenceTable' -ColumnName 'ReferenceID'
    Add-ForeignKey 'SourceTable' 'SourceID' 'ReferenceTable' 'ReferenceID' -Name 'Foreign_Key_Example'

    Disable-ForeignKey 'SourceTable' 'SourceID' 'ReferenceTable' -Name 'Foreign_Key_Example'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'DisabledForeignKeyWithName'

    Invoke-Rivet -Push 'DisabledForeignKeyWithName'

    $ForeignKeys = @(Invoke-RivetTestQuery -Query 'select * from sys.foreign_keys')

    Assert-Equal 'Foreign_Key_Example' $ForeignKeys.Name
    Assert-True $ForeignKeys.is_disabled
}

