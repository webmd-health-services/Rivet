[CmdletBinding()]
param(
)

#Requires -Version 4
Set-StrictMode -Version Latest

$uploadTestResults = $false 
$uploadUri = ''
$baseUploadUri = 'https://ci.appveyor.com/api/testresults/'
$webClient = New-Object 'Net.WebClient'

if( Test-Path -Path 'env:APPVEYOR' )
{
    $uploadTestResults = $true
}

$testRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Test'

# Let's get full stack traces in our errors.
$bladeLogPath = Join-Path -Path $PSScriptRoot -ChildPath '.output\blade.xml'
& {
    $Global:VerbosePreference = 'SilentlyContinue'
    & (Join-Path -Path $PSScriptRoot -ChildPath '.\Tools\Blade\blade.ps1' -Resolve) -Path $testRoot -XmlLogPath $bladeLogPath
}

if( $uploadTestResults )
{
    $uploadUri = '{0}nunit/{1}' -f $baseUploadUri,$env:APPVEYOR_JOB_ID 
    $webClient.UploadFile($uploadUri, $bladeLogPath)
}

if( $LastBladeResult.Failures -or $LastBladeResult.Errors )
{
    Write-Error -Message ('{0} Blade tests failed, and {1} tests had errors. Check the build reports for more details.' -f $LastBladeResult.Failures,$LastBladeResult.Errors) -ErrorAction Stop
    exit 1
}

exit 0
