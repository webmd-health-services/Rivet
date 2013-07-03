
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
    $pstepTestRoot = Join-Path $dbsRoot PstepTest

    & $pstepPath -New -Name 'ShouldCreateOneMigration' -Database PstepTest -Path $pstepTestRoot
    Assert-True $?
    Assert-LastProcessSucceeded
    
    Assert-DirectoryExists $pstepTestRoot
    $migrationRoot = Join-Path $pstepTestRoot Migrations
    Assert-DirectoryExists $migrationRoot
    
    $id = (Get-Date).ToString('yyyyMMddHHmm')
    $migrationPath = Join-Path $pstepTestRoot "Migrations\$($id)??_ShouldCreateOneMigration.ps1"
    Assert-True (Test-Path -Path $migrationPath -PathType Leaf)
    $migration = Get-Item -Path $migrationPath
    Assert-NotNull $migration
    Assert-True ($migration -is [IO.FileInfo])
}

function Test-ShouldCreateMultipleMigrations
{
    $id = (Get-Date).ToString('yyyyMMddHHmm')

    & $pstepPath -New -Name 'ShouldCreateMultipleMigrations' -Database PstepTest,PstepTest2 -Path $dbsRoot
    Assert-True $?
    Assert-LastProcessSucceeded
    
    ('PstepTest','PstepTest2') | ForEach-Object {
        
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