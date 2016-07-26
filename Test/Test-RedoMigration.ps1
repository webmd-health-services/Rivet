
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldPopThenPushTopMigration
{
    @'
function Push-Migration()
{
    Add-Table 'RedoMigration' {
        Int 'id' -Identity
    }
}

function Pop-Migration()
{
    Remove-Table 'RedoMigration'
}
'@ | New-TestMigration -Name 'CreateTable'

    @'
function Push-Migration()
{
    Update-Table -Name 'RedoMigration' -AddColumn {
        Varchar 'description' -Max 
    }

    Add-Table 'SecondTable' {
        Int 'id' -Identity
    }
}

function Pop-Migration()
{
    Remove-Table 'SecondTable' 

    Update-Table 'RedoMigration' -Remove 'description'
}
'@ | New-TestMigration -Name 'AddColumn'

    Invoke-RTRivet -Push

    $redoMigrationTable = Get-Table -Name 'RedoMigration'
    $secondTable = Get-Table -Name 'SecondTable'

    $migrationInfo = Get-MigrationInfo -Name 'AddColumn'
    Assert-NotNull $migrationInfo

    Invoke-RTRivet -Redo
    
    # Make sure only one migration was popped/pushed.
    $redoMigrationTableRedo = Get-Table -Name 'RedoMigration'
    Assert-Equal $redoMigrationTable.create_date $redoMigrationTableRedo.create_date

    $secondTableRedo = Get-Table -Name 'SecondTable'
    Assert-NotNull $secondTableRedo
    Assert-True ($redoMigrationTable.create_date -lt $secondTableRedo.create_date)

    $redoMigrationInfo = Get-MigrationInfo -Name 'AddColumn'
    Assert-NotNull $redoMigrationInfo
    Assert-True ($migrationInfo.AtUtc -lt $redoMigrationInfo.AtUtc)
}
