
function New-Migration
{
    <#
    .SYNOPSIS
    Creates a new migration script.
    
    .DESCRIPTION
    Creates a migration script with a given name.  The script is prefixed with the current timestamp (e.g. yyyyMMddHHmmss).  The script is created in `$Path\$Database\Migrations`.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string[]]
        # The name of the migration to create.
        $Name,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the directory where the migration should be saved.
        $Path
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    foreach( $nameItem in $Name )
    {
        $id = $null
        $id = [int64](Get-Date).ToString('yyyyMMddHHmmss')
        while( (Test-Path -Path $Path -PathType Container) -and `
               (Get-ChildItem -Path $Path -Filter ('{0}_*' -f $id) ) )
        {
            $id++
        }

        $filename = '{0}_{1}.ps1' -f $id,$nameItem

        $importRivetPath = Join-Path -Path $rivetModuleRoot -ChildPath 'Import-Rivet.ps1' -Resolve

        $migrationPath = Join-Path -Path $Path -ChildPath $filename
        $migrationPath = [IO.Path]::GetFullPath( $migrationPath )
        New-Item -Path $migrationPath -Force -ItemType File

        $schemaPs1Path = Join-Path -Path $Path -ChildPath $script:schemaFileName
        if (-not (Test-Path -Path $schemaPs1Path))
        {
            $script:defaultSchemaPs1Content | Set-Content -Path $schemaPs1Path
            $msg = "Rivet created ""$($schemaPs1Path | Resolve-Path -Relative)"", a file where Rivet stores the " +
                   'database''s baseline schema. PLEASE CHECK THIS FILE INTO SOURCE CONTROL.'
            Write-Warning $msg
        }

        $template = @"
<#
Your migration is ready to go!  For the best development experience, please 
write your migration in the PowerShell 3 ISE.  Run the following at a 
PowerShell prompt:

    PS> ise "{0}"
    
or right-click the migration in Windows Explorer and choose "Edit".

The PowerShell ISE gives you intellisense, auto-complete, and other features
you may be used to from the Visual Studio IDE. Use this command in the ISE to
import Rivet and get intellisense/auto-complete:

    PSISE> {1}

The ISE has a "Show Command" add-on which will let you build your migration 
with a GUI.  Once you've got Rivet imported, choose View > Show Command Add-on.
When the Show Command Add-on appears, choose 'Rivet' from the module.  Click on
a migration operation to build it with the Show Command GUI.
#>
function Push-Migration
{{
}}

function Pop-Migration
{{
}}
"@ -f $migrationPath,$importRivetPath 

        $template | Set-Content -Path $migrationPath
    }
}