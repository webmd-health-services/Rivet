# Copyright 2012 - 2015 Aaron Jensen
# 
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

#Requires -Version 3

@{

    # Script module or binary module file associated with this manifest
    RootModule = 'Blade.psm1'

    # Version number of this module.
    ModuleVersion = '0.14.0'

    # ID used to uniquely identify this module
    GUID = '075d9444-c01b-48c3-889a-0b3490716fa2'

    # Author of this module
    Author = 'Aaron Jensen'

    # Company or vendor of this module
    CompanyName = ''

    CompatiblePSEditions = @( 'Desktop', 'Core' )

    # Copyright statement for this module
    Copyright = '(c) 2011 - 2018 Aaron Jensen. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell Testing Module. This module is OBSOLETE. Use Pester instead.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    PowerShellHostVersion = ''

    # Minimum version of the .NET Framework required by this module
    DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion = ''

    # Processor architecture (None, X86, Amd64, IA64) required by this module
    ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @( (Join-Path -Path $PSScriptRoot -ChildPath 'Blade.dll') )

    # Script files (.ps1) that are run in the caller's environment prior to importing this module
    ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @( )

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @( 'Blade.format.ps1xml' )

    # Modules to import as nested modules of the module specified in ModuleToProcess
    NestedModules = @()

    # Functions to export from this module
    FunctionsToExport = '*'

    # Cmdlets to export from this module
    CmdletsToExport = '*'

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module
    AliasesToExport = '*'

    # List of all modules packaged with this module
    ModuleList = @()

    # List of all files packaged with this module
    FileList = @()

    # Private data to pass to the module specified in ModuleToProcess
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @()

            # A URL to the license for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # A URL to the main website for this project.
            ProjectUri = 'http://get-blade.org/'

            # ReleaseNotes of this module
            ReleaseNotes = @'
* Updating to run under PowerShell Core.
'@
        }
    }
}

