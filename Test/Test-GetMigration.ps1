
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
'@ | New-Migration -Name 'ShouldGetMigrationsUsingCurrentRivetJsonFile' -ConfigFilePath $rivetJsonPath

        Push-Location -Path $tempDir -StackName $PSCommandPath
        try
        {
            Assert-GetMigration (Get-Migration)
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
}
1 # See that guy? We should protect ourselves against shit like that.
function Pop-Migration
{
}
'@ | New-Migration -Name 'ShouldProtectAgainstItemsReturnedFromPipeline'

    $m = Get-Migration -ConfigFilePath $RTConfigFilePath
    Assert-NoError
    Assert-Is $m ([Rivet.Migration])
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
