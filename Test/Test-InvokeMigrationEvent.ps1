
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'InvokeMigrationEvent'
    $tempPluginsPath = New-TempDir -Prefix 'InvokeMigrationEvent'
    New-Item -Path (Join-Path -Path $tempPluginsPath -ChildPath '\Plugins\') -ItemType directory
    Start-RivetTest -PluginPath $tempPluginsPath  
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldNotInvokeMigrationEventWhenThereIsNoEventScript
{     
    Invoke-Rivet -Push 'ShouldInvokeMigrationEvent'
    Assert-Table -Name Table1
    Assert-Column -TableName Table1 -Name ColumnA -DataType Int -NotNull
    Assert-False (Test-Column -TableName Table1 -Name CreatedAt)
}

function Test-ShouldInvokeMigrationEvent
{    
@'
function Complete-AddTable
    {
        param(

            [string]
            $TableName,

            [string]
            $SchemaName
        )
        
        Update-Table -SchemaName $SchemaName -Name $TableName -AddColumn {
            Date 'CreatedAt' -NotNull
        }
        
    }

'@ | Set-Content -Path (Join-Path -Path $tempPluginsPath -ChildPath '\Plugins\Complete-AddTable.ps1') 

    Invoke-Rivet -Push 'ShouldInvokeMigrationEvent'
    Assert-Table -Name Table1
    Assert-Column -TableName Table1 -Name ColumnA -DataType Int -NotNull
    Assert-Column -TableName Table1 -Name CreatedAt -DataType Date -NotNull
}

function Test-ShouldThrowExceptionifMoreThanOneMigrationEventFunction
{
@'
function Complete-AddTable
    {
        param(

            [string]
            $TableName,

            [string]
            $SchemaName
        )

        Update-Table -SchemaName $SchemaName -Name $TableName -AddColumn {
            Date 'CreatedAt' -NotNull
        }
        
    }

function Complete-IShouldNotBeHere
    {
        Write-Host "Not here"
    }

'@ | Set-Content -Path (Join-Path -Path $tempPluginsPath -ChildPath '\Plugins\Complete-AddTable.ps1')

    ## Test that the error is caught
    Invoke-Rivet -Push 'ShouldInvokeMigrationEvent' -ErrorAction SilentlyContinue -ErrorVariable rivetError
    Assert-True ($rivetError.Count -gt 0)
    Assert-Like $rivetError '*function count in migration event is 2*'
    
    ## Test that the migration is not applied if there is an error
    Assert-False (Test-Table -Name Table1) ('table Table1 created')
    $migration = Get-MigrationInfo -Name Table1
    Assert-Null $migration 
}

function Test-ShouldThrowExceptionifEventNameIsWrong
{
@'
function Complete-WrongName
    {
        param(

            [string]
            $TableName,

            [string]
            $SchemaName
        )

        Update-Table -SchemaName $SchemaName -Name $TableName -AddColumn {
            Date 'CreatedAt' -NotNull
        }
        
    }

'@ | Set-Content -Path (Join-Path -Path $tempPluginsPath -ChildPath '\Plugins\Complete-AddTable.ps1')

    ## Test that the error is caught
    Invoke-Rivet -Push 'ShouldInvokeMigrationEvent' -ErrorAction SilentlyContinue -ErrorVariable rivetError
    Assert-True ($rivetError.Count -gt 0)
    Assert-Like $rivetError '*Invalid Event Name: Complete-WrongName*'
    
    ## Test that the migration is not applied if there is an error
    Assert-False (Test-Table -Name Table1) ('table Table1 created')
    $migration = Get-MigrationInfo -Name Table1
    Assert-Null $migration 
}

function Test-ShouldThrowExceptionIfThereIsASyntaxError
{
@'
function Complete-AddTable
    {
        param(

            [string]
            $TableName,

            [string]
            $SchemaName
        )

        Update-Table -SchemaName $SchemaName -Name $TableName -AddColumn {
            Date 'CreatedAt' -NotNull
        }

        Poop
    }

'@ | Set-Content -Path (Join-Path -Path $tempPluginsPath -ChildPath '\Plugins\Complete-AddTable.ps1')

    ## Test that the error is caught
    Invoke-Rivet -Push 'ShouldInvokeMigrationEvent' -ErrorAction SilentlyContinue -ErrorVariable rivetError
    Assert-True ($rivetError.Count -gt 0)
    Assert-Like $rivetError '*The term ''Poop'' is not recognized*'
    
    ## Test that the migration is not applied if there is an error
    Assert-False (Test-Table -Name Table1) ('table Table1 created')
    $migration = Get-MigrationInfo -Name Table1
    Assert-Null $migration 
}
