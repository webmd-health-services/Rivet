
$dbsRoot = $null
$rivetPath = Join-Path $TestDir ..\Rivet\rivet.ps1 -Resolve

function Setup
{
    $dbsRoot = New-TempDir
}

function TearDown
{
    if( (Test-Path -Path $dbsRoot -PathType Container) )
    {
        Remove-Item -Path $dbsRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Test-ShouldCreateOneMigration
{
    $rivetTestRoot = Join-Path $dbsRoot RivetTest

    & $rivetPath -New -Name 'ShouldCreateOneMigration' -Database RivetTest -Path $rivetTestRoot
    Assert-True $?
    Assert-LastProcessSucceeded
    
    Assert-DirectoryExists $rivetTestRoot
    $migrationRoot = Join-Path $rivetTestRoot Migrations
    Assert-DirectoryExists $migrationRoot
    
    $id = (Get-Date).ToString('yyyyMMddHHmm')
    $migrationPath = Join-Path $rivetTestRoot "Migrations\$($id)??_ShouldCreateOneMigration.ps1"
    Assert-True (Test-Path -Path $migrationPath -PathType Leaf)
    $migration = Get-Item -Path $migrationPath
    Assert-NotNull $migration
    Assert-True ($migration -is [IO.FileInfo])
}

function Test-ShouldCreateMultipleMigrations
{
    $id = (Get-Date).ToString('yyyyMMddHHmm')

    & $rivetPath -New -Name 'ShouldCreateMultipleMigrations' -Database RivetTest,RivetTest2 -Path $dbsRoot
    Assert-True $?
    Assert-LastProcessSucceeded
    
    ('RivetTest','RivetTest2') | ForEach-Object {
        
        $dbRoot = Join-Path $dbsRoot $_
        Assert-DirectoryExists $dbRoot
        $migrationRoot = Join-Path $dbRoot Migrations
        Assert-DirectoryExists $migrationRoot
        
        $migrationPath = Join-Path $dbsRoot "$_\Migrations\$($id)??_ShouldCreateMultipleMigrations.ps1"
        Assert-True (Test-Path -Path $migrationPath -PathType Leaf)
        $migration = Get-Item -Path $migrationPath
        Assert-NotNull $migration
        Assert-True ($migration -is [IO.FileInfo])
    }
}