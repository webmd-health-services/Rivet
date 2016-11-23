<#
.SYNOPSIS
Packages and publishes Carbon packages.
#>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[CmdletBinding()]
param(
    [Version]
    # The version to build. If not supplied, build the version as currently defined.
    $Version,

    [Switch]
    $Clean
)

#Requires -Version 4
Set-StrictMode -Version Latest

& (Join-Path -Path $PSScriptRoot -ChildPath 'Silk\Import-Silk.ps1' -Resolve)

.\init.ps1 

$outputRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Output'
Install-Directory -Path $outputRoot

if( $Clean )
{
    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Source') -Include 'bin','obj' -Directory -Recurse | Remove-Item -Recurse
    Get-ChildItem -Path $outputRoot | Remove-Item -Recurse -WhatIf
}

Set-ModuleVersion -ManifestPath (Join-Path -Path $PSScriptRoot -ChildPath 'Rivet\Rivet.psd1') `
                  -SolutionPath (Join-Path -Path $PSScriptRoot -ChildPath 'Source\Rivet.sln') `
                  -AssemblyInfoPath (Join-Path -Path $PSScriptRoot -ChildPath 'Source\Properties\AssemblyVersion.cs') `
                  -Version $Version `
                  -ReleaseNotesPath (Join-Path -Path $PSScriptRoot -ChildPath 'RELEASE_NOTES.txt' -Resolve) `
                  -NuspecPath (Join-Path -Path $PSScriptRoot -ChildPath 'Rivet.nuspec' -Resolve) 


$uploadTestResults = $false 
$uploadUri = ''
$baseUploadUri = 'https://ci.appveyor.com/api/testresults/'
$webClient = New-Object 'Net.WebClient'

if( Test-Path -Path 'env:APPVEYOR' )
{
    $uploadTestResults = $true
}

$failed = $false

$xmlLogPath = $outputRoot
$nunitLogPath = Join-Path -Path $xmlLogPath -ChildPath 'nunit.xml'

$nunitPath = Join-Path -Path $PSScriptRoot -ChildPath 'packages\NUnit.ConsoleRunner\tools\nunit3-console.exe' -Resolve
& $nunitPath (Join-Path -Path $PSScriptRoot -ChildPath 'Source\Test\bin\*\Rivet.Test.dll' -Resolve) "--result=$nunitLogPath;format=nunit3"
$failedTests = $LASTEXITCODE
if( $uploadTestResults )
{
    $uploadUri = '{0}nunit3/{0}' -f $baseUploadUri,$env:APPVEYOR_JOB_ID 
    Write-Verbose -Message $uploadUri
    Write-Verbose -Message $nunitLogPath
    $webClient.UploadFile($uploadUri, $nunitLogPath)
}

if( $LASTEXITCODE -ne 0 )
{
    Write-Error -Message ('{0} NUnit tests failed. Check the build reports for more details.' -f $LASTEXITCODE)
}

robocopy /MIR (Join-Path -Path $PSScriptRoot -ChildPath 'Source\bin\Debug') (Join-Path -Path $PSScriptRoot -ChildPath 'Rivet\bin') /NJH /NJS /NP /NDL

$testRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Test'

# Let's get full stack traces in our errors.
$bladeLogPath = Join-Path -Path $xmlLogPath -ChildPath 'blade.xml'
& (Join-Path -Path $PSScriptRoot -ChildPath '.\Tools\Blade\blade.ps1' -Resolve) -Path $testRoot -XmlLogPath $bladeLogPath

if( $uploadTestResults )
{
    $uploadUri = '{0}nunit/{0}' -f $baseUploadUri,$env:APPVEYOR_JOB_ID 
    $webClient.UploadFile($uploadUri, $bladeLogPath)
}

if( $LastBladeResult.Failures -or $LastBladeResult.Errors )
{
    Write-Error -Message ('{0} Blade tests failed, and {1} tests had errors. Check the build reports for more details.' -f $LastBladeResult.Failures,$LastBladeResult.Errors)
    $failed = $true
}

$pesterLogPath = Join-Path -Path $xmlLogPath -ChildPath 'pester.xml'
if( (Get-Module -Name 'Pester') )
{
    Remove-Module -Name 'Pester'
}
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Pester' -Resolve)
$result = Invoke-Pester -Script $testRoot -OutputFile $pesterLogPath -OutputFormat NUnitXml -PassThru |
                Select-Object -Last 1
$result

if( $uploadTestResults )
{
    $uploadUri = '{0}nunit3/{0}' -f $baseUploadUri,$env:APPVEYOR_JOB_ID 
    $webClient.UploadFile($uploadUri, $pesterLogPath)
}

if( $result.FailedCount )
{
    Write-Error -Message ('{0} Pester tests failed. Check the NUnit reports for more details.' -f $result.FailedCount)
    $failed = $true
}

if( $failed )
{
    exit 1
}
