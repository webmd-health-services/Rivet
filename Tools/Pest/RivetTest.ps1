[CmdletBinding()]
param(
[string] $Path
)

clear

$lastRivetTestFile = (Join-Path (Split-Path $profile) "lastRivetTest.clixml")
$test = (Get-ChildItem $Path | Where-Object { $_ -match 'Test-' }).Name
$selection = 0

if ($test -eq $null)
{
    Write-Host "No Tests Found"
    Write-Host ""
    return
}

function getFunctionsinFile([int]$selection) #pass some parameters!!!
{
    
    $testpath = Join-Path $Path ($test[$selection-1])
    $testScriptContent = Get-Content $testpath

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
            [void]$functions.Add( $token.Content )
            $atFunction = $false
        }
    }

    ## Remove Setup, Teardown, Ignore
    ## Strip Test header

    $functions | 
        Where-Object { $_ -match 'Test-' } |
        ForEach-Object {$_ -replace "Test-", ""} | Sort-Object

}


function recallPreviousTest
{

    $lastRivetTest = Import-Clixml $lastRivetTestFile

    ## Test for All Tests
    if ($lastRivetTest."Test".Equals("All"))
    {
        [string]$selection = Read-Host "Enter to run all Rivet tests again?"

        if ($selection -eq '' -or $selection -eq 'y')
        {
            Export-Clixml -Path $lastRivetTestFile -InputObject ($lastRivetTest = @{Test = "All"; SubTest = ""})
            .\Tools\Pest\pest.ps1 -Path $Path
            exit 1
        }
        else
        {
            return
        }
    }

    ## Test for Specific Tests
    $testpath = Join-Path $Path $test[$lastRivetTest."Test"-1]

    if ($lastRivetTest."SubTest" -eq 0)
    {
        [string]$selection = Read-Host "Enter to run all"  $test[$lastRivetTest."Test"-1]  "tests again?"

        if ($selection -eq '' -or $selection -eq 'y')
        {
            Export-Clixml -Path $lastRivetTestFile -InputObject ($lastRivetTest = @{Test = $lastRivetTest."Test"; SubTest = 0})
            .\Tools\Pest\pest.ps1 -Path $testpath
            exit 1
        }
        else
        {
            return
        }    
    }
    else
    {
        $functions = @(getFunctionsinFile $lastRivetTest."Test"-1)
        [string]$selection = Read-Host "Enter to run"  $functions[($lastRivetTest."SubTest")-1] "in" $test[$lastRivetTest."Test"-1]  "again?"

        if ($selection -eq '' -or $selection -eq 'y')
        {
            Export-Clixml -Path $lastRivetTestFile -InputObject ($lastRivetTest = @{Test = $lastRivetTest."Test"; SubTest = $lastRivetTest."SubTest"})
            .\Tools\Pest\pest.ps1 -Path $testpath -Test $functions[($lastRivetTest."SubTest")-1]
            exit 1
        }
        else
        {
            return
        }  
    }


}

## Recall previous test

if (Test-Path $lastRivetTestFile)
{
    recallPreviousTest
}

## Display tests
if (Test-Path $lastRivetTestFile)
{
    Remove-Item $lastRivetTestF ile
}

Write-Host "** RIVET TESTS **"
Write-Host " "
$counter = 0
$test | ForEach-Object {
    Write-Host ($counter+1)'.' ($test[$counter])
    ++$counter
}
Write-Host " "

## Get User Selection
do
{
    try
    {
        $numOK = $false
        [int]$selection = Read-Host "Which Test Would You Like to Run? (Enter for all)"
    }
    catch
    {
        $numOK = $true
    }
} while ($selection -lt 0 -or $selection -gt $test.Count -or $numOK)


## Test for (Enter for all)
if ($selection -eq 0)
{
    Export-Clixml -Path $lastRivetTestFile -InputObject ($lastRivetTest = @{Test = "All"; SubTest = ""})
    .\Tools\Pest\pest.ps1 -Path $Path
    return
}

## Get Functions in File
$functions = @(getFunctionsinFile $selection)

## Display Sub Tests
clear
$message = "** " + $test[$selection-1] + " Sub-Tests **"
Write-Host $message
Write-Host " "

$counter = 0
$functions | ForEach-Object {
    Write-Host ($counter+1)'.' ($functions[$counter])
    ++$counter
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

$lastRivetTest = $null
Export-Clixml -Path $lastRivetTestFile -InputObject ($lastRivetTest = @{Test = $selection; SubTest = $subTestSelection})

$Path = Join-Path $Path ($test[$selection-1])
## Run Test

if ($subTestSelection -eq 0)
{
    .\Tools\Pest\pest.ps1 -Path $Path
}
else
{
    .\Tools\Pest\pest.ps1 -Path $Path -Test $functions[$subTestSelection-1]
}
