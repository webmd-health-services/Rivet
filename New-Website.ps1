<#
.SYNOPSIS
Creates the get-rivet.org website.

.DESCRIPTION
The `New-Website.ps1` script generates the get-rivet.org website. It uses the Silk module for Markdown to HTML conversion.
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
    [Switch]
    # Skips generating the command help.
    $SkipCommandHelp
)

#Requires -Version 4
Set-StrictMode -Version 'Latest'

function Out-HtmlPage
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias('Html')]
        # The contents of the page.
        $Content,

        [Parameter(Mandatory=$true)]
        # The title of the page.
        $Title,

        [Parameter(Mandatory=$true)]
        # The path under the web root of the page.
        $VirtualPath
    )

    begin
    {
        Set-StrictMode -Version 'Latest'
    }

    process
    {

        $webRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Website'
        $path = Join-Path -Path $webRoot -ChildPath $VirtualPath
        $templateArgs = @(
                            $Title,
                            $Content,
                            (Get-Date).Year
                        )
        @'
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>{0}</title>
    <link href="silk.css" type="text/css" rel="stylesheet" />
	<link href="styles.css" type="text/css" rel="stylesheet" />
</head>
<body>

    <ul id="SiteNav">
		<li><a href="index.html">Get-Rivet</a></li>
        <!--<li><a href="about_Carbon_Installation.html">-Install</a></li>-->
		<li><a href="documentation.html">-Documentation</a></li>
        <!--<li><a href="about_Carbon_Support.html">-Support</a></li>-->
        <li><a href="releasenotes.html">-ReleaseNotes</a></li>
		<li><a href="http://pshdo.com">-Blog</a></li>
    </ul>

    {1}

	<div class="Footer">
		Copyright 2013 - {2} <a href="http://pshdo.com">Aaron Jensen</a>.
	</div>

</body>
</html>
'@ -f $templateArgs | Set-Content -Path $path
    }

    end
    {
    }
}


& (Join-Path -Path $PSScriptRoot -ChildPath 'Silk\Import-Silk.ps1' -Resolve)

if( (Get-Module -Name 'Blade') )
{
    Remove-Module 'Blade'
}

& (Join-Path -Path $PSScriptRoot -ChildPath '.\Rivet\Import-Rivet.ps1' -Resolve)

$headingMap = @{
               }

$scripts = @( 'Import-Rivet.ps1', 'rivet.ps1' )

Convert-ModuleHelpToHtml -ModuleName 'Rivet' -HeadingMap $headingMap -SkipCommandHelp:$SkipCommandHelp -Script $scripts |
    ForEach-Object { Out-HtmlPage -Title ('PowerShell - {0} - Rivet' -f $_.Name) -VirtualPath ('{0}.html' -f $_.Name) -Content $_.Html }

New-ModuleHelpIndex -TagsJsonPath (Join-Path -Path $PSScriptRoot -ChildPath 'tags.json') -ModuleName 'Rivet' -Script $scripts |
     Out-HtmlPage -Title 'PowerShell - Rivet Documentation' -VirtualPath '/documentation.html'

$rivetTitle = 'Rivet: Evolutionary Database Migration Tool for SQL Server'
Get-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Rivet\en-US\about_Rivet.help.txt') |
    Convert-AboutTopicToHtml -ModuleName 'Rivet' -Script $scripts |
    ForEach-Object {
        $_ -replace '<h1>about_Rivet</h1>','<h1>Rivet</h1>'
    } |
    Out-HtmlPage -Title $rivetTitle -VirtualPath '/index.html'

Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'RELEASE_NOTES.txt') -Raw | 
    Edit-HelpText -ModuleName 'Rivet' |
    Convert-MarkdownToHtml | 
    Out-HtmlPage -Title ('Release Notes - {0}' -f $rivetTitle) -VirtualPath '/releasenotes.html'

Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Silk\Resources\silk.css' -Resolve) `
          -Destination (Join-Path -Path $PSScriptRoot -ChildPath 'Website') -Verbose