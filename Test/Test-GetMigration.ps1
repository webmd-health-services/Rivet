
& (Join-Path -Path $PSScriptRoot -ChildPath '.\RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldGetMigrationsUsingCurrentRivetJsonFile
{
    $tempDir = New-TempDirectoryTree -Prefix $PSCommandPath -Tree (@'
* rivet.json
+ Databases
  + {0}
    + Migrations
'@ -f $RTDatabaseName)

    try
    {
        $rivetJsonPath = Join-Path -Path $tempDir -ChildPath 'rivet.json'
        (@'
    {{
        DatabasesRoot: 'Databases',
        SqlServerName: '{0}'
    }}
'@ -f ([Web.HttpUtility]::JavaScriptStringEncode($RTServer))) | Set-Content -Path $rivetJsonPath

        @'
    function Push-Migration
    {
        Add-Schema 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
    }

    function Pop-Migration
    {
        Remove-Schema 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
    }
'@ | New-TestMigration -Name 'ShouldGetMigrationsUsingCurrentRivetJsonFile' -ConfigFilePath $rivetJsonPath | Format-Table | Out-String | Write-Verbose

        Push-Location -Path $tempDir -StackName $PSCommandPath
        try
        {
            Assert-GetMigration (Get-Migration)
            Assert-GetMigration (Get-Migration -Database $RTDatabaseName  -ConfigFilePath (Join-Path -Path $tempDir -ChildPath 'rivet.json'))
            Assert-NoError
        }
        finally
        {
            Pop-Location -StackName $PSCommandPath
        }

        # Now, use an explicit path.
        Assert-GetMigration (Get-Migration -ConfigFilePath $rivetJsonPath)
    }
    finally
    {
        Remove-Item -Path $tempDir -Recurse
    }
}

function Test-ShouldProtectAgainstItemsReturnedFromPipeline
{
    @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
1 # See that guy? We should protect ourselves against shit like that.
function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'ShouldProtectAgainstItemsReturnedFromPipeline'

    $m = Get-Migration -ConfigFilePath $RTConfigFilePath
    Assert-NoError
    Assert-Is $m ([Rivet.Migration])
}

function Test-ShouldRejectMigrationWithEmptyPush
{
    $m = @'
function Push-Migration
{
    # I'm empty. That is bad!
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'EmptyPush'

    try
    {
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
        Assert-Null $result
        Assert-Error -Last -Regex 'Push-Migration.*empty'
    }
    finally
    {
        Remove-Item -Path $m.FullName
    }
}

function Test-ShouldRejectMigrationWithEmptyPop
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    # I'm empty. That is bad!
}
'@ | New-TestMigration -Name 'EmptyPop'

    try
    {
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
        Assert-Null $result
        Assert-Error -Last -Regex 'Pop-Migration.*empty'
    }
    finally
    {
        Remove-Item -Path $m.FullName
    }
}

function Test-ShouldRejectMigrationWithNoPushMigrationFunction
{
    $m = @'
function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'MissingPush'

    try
    {
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
        Assert-Null $result
        Assert-Error -Last -Regex 'Push-Migration.*not found'
    }
    finally
    {
        Remove-Item -Path $m.FullName
    }
}

function Test-ShouldRejectMigrationWithNoPopMigrationFunction
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'MissingPop'

    try
    {
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
        Assert-Null $result
        Assert-Error -Last -Regex 'Pop-Migration.*not found'
    }
    finally
    {
        Remove-Item -Path $m.FullName
    }
}

function Test-ShouldWriteAnErrorIfIncludedMigrationNotFound
{
    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include 'nomigrationbythisname' -ErrorAction SilentlyContinue
    Assert-Null $result
    Assert-Error -Last -Regex 'Migration ''nomigrationbythisname'' not found\.'
}

function Test-ShouldNotWriteAnErrorIfIncludedWildcardedMigrationNotFound
{
    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include '*fubar*'
    Assert-Null $result
    Assert-NoError
}

function Test-ShouldIncludeMigrationByNameOrID
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'ShouldIncludeMigrationByNameOrID'

    $id = ($m.BaseName -split '_')[0]

    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include 'ShouldIncludeMigrationByNameOrID'
    Assert-NotNull $result
    Assert-Equal $result.ID $id
    Assert-Equal $result.Name 'ShouldIncludeMigrationByNameOrID'
    Assert-Equal $result.FullName $m.BaseName

    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include $id
    Assert-NotNull $result
    Assert-Equal $result.ID $id
    Assert-Equal $result.Name 'ShouldIncludeMigrationByNameOrID'
    Assert-Equal $result.FullName $m.BaseName
}

function Test-ShouldIncludeMigrationWildcardID
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'ShouldIncludeMigrationWildcardID'

    $id = ($m.BaseName -split '_')[0]

    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include ('{0}*' -f $id.Substring(0,10))
    Assert-NotNull $result
    Assert-Equal $result.ID $id
    Assert-Equal $result.Name 'ShouldIncludeMigrationWildcardID'
    Assert-Equal $result.FullName $m.BaseName
}

function Test-ShouldGetAMigrationByBaseName
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'ShouldGetAMigrationByBaseName'

    $id = ($m.BaseName -split '_')[0]

    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include $m.BaseName
    Assert-NotNull $result
    Assert-Equal $result.ID $id
    Assert-Equal $result.Name 'ShouldGetAMigrationByBaseName'
    Assert-Equal $result.FullName $m.BaseName
}

function Test-ShouldGetAMigrationByBaseNameWithWildcard
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'ShouldGetAMigrationByBaseNameWithWildcard'

    $id = ($m.BaseName -split '_')[0]

    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include ('{0}*' -f $m.BaseName.Substring(0,20))
    Assert-NotNull $result
    Assert-Equal $result.ID $id
    Assert-Equal $result.Name 'ShouldGetAMigrationByBaseNameWithWildcard'
    Assert-Equal $result.FullName $m.BaseName
}

function Test-ShouldExcludeMigrationByNameOrID
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'ShouldExcludeMigrationByNameOrID'


    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude 'ShouldExcludeMigrationByNameOrID'
    Assert-NoError
    Assert-Null $result

    $id = ($m.BaseName -split '_')[0]
    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude $id
    Assert-NoError
    Assert-Null $result
}

function Test-ShouldExcludeMigrationWildcardID
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'ShouldExcludeMigrationWildcardID'

    $id = ($m.BaseName -split '_')[0]

    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude ('{0}*' -f $id.Substring(0,10))
    Assert-NoError
    Assert-Null $result
}

function Test-ShouldExcludeAMigrationByBaseName
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'ShouldExcludeAMigrationByBaseName'

    $id = ($m.BaseName -split '_')[0]

    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude $m.BaseName
    Assert-NoError
    Assert-Null $result
}

function Test-ShouldExcludeAMigrationByBaseNameWithWildcard
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | New-TestMigration -Name 'ShouldExcludeAMigrationByBaseNameWithWildcard'

    $id = ($m.BaseName -split '_')[0]

    $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude ('{0}*' -f $m.BaseName.Substring(0,20))
    Assert-NoError
    Assert-Null $result
}

function Assert-GetMigration
{
    param(
        [Rivet.Migration]
        $m
    )

    Set-StrictMode -Version 'Latest'
    Assert-NoError
    Assert-NotNull $m
    Assert-Is $m ([Rivet.Migration])
    Assert-Equal 'ShouldGetMigrationsUsingCurrentRivetJsonFile' $m.Name

    Assert-Equal 1 $m.PushOperations.Count
    $pushOp = $m.PushOperations[0]
    Assert-Is $pushOp ([Rivet.Operations.AddSchemaOperation])
    Assert-Equal 'ShouldGetMigrationsUsingCurrentRivetJsonFile' $pushOp.Name

    Assert-Equal 1 $m.PopOperations.Count
    $popOp = $m.PopOperations[0]
    Assert-Is $popOp ([Rivet.Operations.RemoveSchemaOperation])
    Assert-Equal 'ShouldGetMigrationsUsingCurrentRivetJsonFile' $popOp.Name

}
