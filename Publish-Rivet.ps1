<#
.SYNOPSIS
Packages and publishes Rivet packages.

.DESCRIPTION
The `Publish-Rivet.ps1` script packages and publishes a version of the Rivet module. It use the version defined in the Rivet.psd1 file. Before publishing, it adds the current date to the version in the release notes, updates the module's website, then tags the latest revision with the version number. It then publishes the module to Bitbucket, NuGet, Chocolatey, and PowerShell Gallery. If the version of Rivet being publishes already exists in a location, it is not re-published. If the PowerShellGet module isn't installed, the module is not publishes to the PowerShell Gallery.

.EXAMPLE
Publish-Carbon.ps1

Yup. That's it.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]
    $AppveyorApiToken,

    [Parameter(Mandatory=$true)]
    [string]
    $Version,

    [string]
    # The name of the artifact to get. Default is 'PowerShell'
    $ArtifactName = 'PowerShell'
)

#Requires -Version 4
Set-StrictMode -Version Latest

& (Join-Path -Path $PSScriptRoot -ChildPath 'Silk\Import-Silk.ps1' -Resolve)

$moduleName = 'Rivet'
$licenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'
$tags = @( 'sql-server','evolutionary-database','database','migrations' )
$projectUri = 'http://get-rivet.org'

$baseApiUri = 'https://ci.appveyor.com/api'
$headers = @{
              "Authorization" = ("Bearer {0}" -f $AppveyorApiToken)
              "Content-type" = "application/json"
            }
$accountName = 'splatteredbits'
$projectSlug = $moduleName.ToLowerInvariant()

$downloadLocation = Join-Path -Path $env:TEMP -ChildPath ([IO.Path]::GetRandomFileName())
New-Item -Path $downloadLocation -ItemType 'Directory' | Out-String | Write-Verbose

# get project with last build details
$project = Invoke-RestMethod -Method Get -Uri ("{0}/projects/{1}/{2}/build/{3}" -f $baseApiUri,$accountName,$projectSlug,$Version) -Headers $headers
if( $project.build.status -ne 'success' )
{
    Write-Error -Message ('Build {0} didn''t succeed. Its status is ''{1}''.' -f $Version,$project.build.status)
    return
}

$jobId = $project.build.jobs[0].jobId

# get job artifacts (just to see what we've got)
$artifacts = Invoke-RestMethod -Method Get -Uri ("{0}/buildjobs/{1}/artifacts" -f $baseApiUri,$jobId) -Headers $headers

$artifact = $artifacts | Where-Object { $_.name -eq $ArtifactName }
if( -not $artifact )
{
    Write-Error -Message ('Artifact ''{0}'' does not exist. We did find these named artifacts: {1}' -f $ArtifactName,($artifacts | ConvertTo-Json))
    return
}

$artifactFileName = $artifact.fileName

# artifact will be downloaded as
$localArtifactPath = Join-Path -Path $downloadLocation -ChildPath $artifactFileName
$localArtifactRoot = Split-Path -Path $localArtifactPath -Parent
if( -not (Test-Path -Path $localArtifactRoot -PathType Container) )
{
    New-item -Path $localArtifactRoot -ItemType 'Directory' | Out-String | Write-Verbose
}

Invoke-RestMethod -Method Get `
                  -Uri ("{0}/buildjobs/{1}/artifacts/{2}" -f $baseApiUri,$jobId,$artifactFileName) `
                  -OutFile $localArtifactPath `
                  -Headers @{ "Authorization" = ("Bearer {0}" -f $AppveyorApiToken) }

Add-Type -AssemblyName 'System.IO.Compression.FileSystem'

$extractPath = Join-Path -Path $downloadLocation -ChildPath $moduleName
New-Item -Path $extractPath -ItemType 'Directory' | Out-String | Write-Verbose

[IO.Compression.ZipFile]::ExtractToDirectory( $localArtifactPath, $extractPath )

Publish-PowerShellGalleryModule -ManifestPath (Join-Path -Path $extractPath -ChildPath ('{0}.psd1' -f $moduleName)) `
                                -ModulePath $extractPath `
                                -ReleaseNotesPath (Join-Path -Path $extractPath -ChildPath 'RELEASE_NOTES.txt') `
                                -LicenseUri $licenseUri `
                                -Tags $tags `
                                -ProjectUri $projectUri
