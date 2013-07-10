<#
$definition = @{ 
    1 = 'Value1';
    2 = 'Value2';
}

$o = New-Object PsObject -Property $de$definition | 
        Add-Member ScriptMethod -Name 'Method1' -Value { $this.Property1 + " " + $this.Property2 } -PassThru

$o | get-member

return
#>


clear

## Store Names of Tests

$test = @{

    1 = 'Add Column', 'Test-AddColumn.ps1';
    2 = 'Add Description', 'Test-AddDescription.ps1';
    3 = 'Add Table', 'Test-AddTable.ps1';
    4 = 'Initialize Database', 'Test-InitializeDatabase.ps1';
    5 = 'New Migration', 'Test-NewMigration.ps1';
    6 = 'Pop Migration', 'Test-PopMigration.ps1';
    7 = 'Push Migration', 'Test-PushMigration.ps1';
    8 = 'Redo Migration', 'Test-RedoMigration.ps1';
    9 = 'Remove Column', 'Test-RemoveColumn.ps1';
    10 = 'Remove Description', 'Test-RemoveDescription.ps1';
    11 = 'Remove Table', 'Test-RemoveTable.ps1';
    12 = 'Update Description', 'Test-UpdateDescription.ps1';
}

## Display tests

$message = "** RIVET TESTS **"
Write-Host $message
Write-Host " "

for ($counter = 1; $counter -le $test.Count; $counter++)
{
    Write-Host ($counter)'.' ($test[$counter])[0]
}

Write-Host " "

## Get User Selection
do
{
    try
    {
        $numOK = $false
        [int]$selection = Read-Host "Which Test Would You Like to Run?"
    }
    catch
    {
        $numOK = $true
    }
} while ($selection -le 0 -or $selection -gt $test.Count -or $numOK)

## Get Functions in File
$path = Join-Path .\Test\ $test[$selection][1]
$testScriptContent = Get-Content $path

$errors = [Management.Automation.PSParseError[]] @()
$tokens = [System.Management.Automation.PsParser]::Tokenize( $testScriptContent, [ref] $errors )

$functions = New-Object System.Collections.ArrayList
$atFunction = $false
    
for( $idx = 0; $idx -lt $tokens.Count; ++$idx )
{
    $token = $tokens[$idx]
    if( $token.Type -eq 'Keyword'-and $token.Content -eq 'Function' )
    {
        $atFunction = $true
    }
        
    if( $atFunction -and $token.Type -eq 'CommandArgument' -and $token.Content -ne '' )
    {
        Write-Verbose "Found function '$($token.Content).'"
        [void] $functions.Add( $token.Content )
        $atFunction = $false
    }
}

## Remove Setup, Teardown, Ignore

$testfunctions = New-Object System.Collections.ArrayList 

foreach ($i in $functions)
{
    if ($i -match 'Test')
    {
        $null = $testfunctions.Add($i)
    }
}

$functions.Clear()

## Strip Test Header

foreach ($_ in $testfunctions)
{
    $null = $functions.Add($_.replace("Test-",""))
}

$functions

## Display Sub Tests
clear
$message = "** " + $test[$selection][1] + " Sub-Tests **"
Write-Host $message
Write-Host " "

for ($counter = 0; $counter -lt $functions.Count; $counter++)
{
    Write-Host ($counter+1)'.' ($functions[$counter])
}

Write-Host " "

## Select Sub Test, or press enter to run all tests

do
{
    try
    {
        $numOK = $false
        [int]$subTestSelection = Read-Host "Which Test Would You Like to Run? (Enter for all)" 
    }
    catch
    {
        $numOK = $true
    }
} while ($subTestSelection -lt 0 -or $subTestSelection -gt $functions.Count -or $numOK)


## Run Test

if ($subTestSelection -eq 0)
{
    .\Tools\Pest\pest.ps1 -Path $path
}
else
{
    .\Tools\Pest\pest.ps1 -Path $path -Test $functions[$subTestSelection-1]
}
