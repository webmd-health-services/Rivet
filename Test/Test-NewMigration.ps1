
$dbsRoot = $null
$pstepPath = Join-Path $TestDir ..\Pstep\pstep.ps1 -Resolve

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
    & $pstepPath -New -Name 'ShouldCreateOneMigration' -Database One -Path $dbsRoot
    Assert-True $?
    Assert-LastProcessSucceeded
    
    $dbRoot = Join-Path $dbsRoot One
    Assert-DirectoryExists $dbRoot
    $migrationRoot = Join-Path $dbRoot Migrations
    Assert-DirectoryExists $migrationRoot
    
    $id = (Get-Date).ToString('yyyyMMddHHmm')
    $migrationPath = Join-Path $dbsRoot "One\Migrations\$($id)??_ShouldCreateOneMigration.ps1"
    Assert-True (Test-Path -Path $migrationPath -PathType Leaf)
    $migration = Get-Item -Path $migrationPath
    Assert-NotNull $migration
    Assert-True ($migration -is [IO.FileInfo])
}

function Test-ShouldCreateMultipleMigrations
{
    $id = (Get-Date).ToString('yyyyMMddHHmm')

    & $pstepPath -New -Name 'ShouldCreateMultipleMigrations' -Database One,Two -Path $dbsRoot
    Assert-True $?
    Assert-LastProcessSucceeded
    
    ('One','Two') | ForEach-Object {
        
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