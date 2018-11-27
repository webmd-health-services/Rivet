#
# Module manifest for module 'Rivet'
#
# Generated by: Aaron Jensen
#
# Generated on: 1/25/2013
#

@{
    # Script module or binary module file associated with this manifest
    RootModule = 'Rivet.psm1'

    # Version number of this module.
    ModuleVersion = '0.9.0'

    # ID used to uniquely identify this module
    GUID = '8af34b47-259b-4630-a945-75d38c33b94d'

    # Author of this module
    Author = 'WebMD Health Services'

    # Company or vendor of this module
    CompanyName = 'WebMD Health Services'

    CompatiblePSEditions = @( 'Desktop', 'Core' )

    # Copyright statement for this module
    Copyright = 'Copyright 2013 - 2018 WebMD Health Services.'

    # Description of the functionality provided by this module
    Description = @'
Rivet is a database migration/change management/versioning tool inspired by Ruby on Rails' Migrations. It creates and applies migration scripts for SQL Server databases. Migration scripts describe changes to make to your database, e.g. add a table, add a column, remove an index, etc. Migrations scripts should get added to your version control system so they can be packaged and deployed with your application's code.
'@

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
    RequiredAssemblies = @( 'bin\Rivet.dll' )

    # Script files (.ps1) that are run in the caller's environment prior to importing this module
    ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    #TypesToProcess = ''

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @( 
                            'Formats\RivetMigrationResult-GroupingFormat.format.ps1xml',
                            'Formats\RivetOperationResult-GroupingFormat.format.ps1xml',
                            'Formats\Rivet.Migration.format.ps1xml',
                            'Formats\Rivet.OperationResult.format.ps1xml'
                        )

    # Modules to import as nested modules of the module specified in ModuleToProcess
    NestedModules = @( 'bin\Rivet.dll' )

    # Functions to export from this module
    FunctionsToExport = @(
                            'Add-CheckConstraint',
                            'Add-DataType',
                            'Add-DefaultConstraint',
                            'Add-Description',
                            'Add-ExtendedProperty',
                            'Add-ForeignKey',
                            'Add-PrimaryKey',
                            'Add-Row',
                            'Add-RowGuidCol',
                            'Add-Schema',
                            'Add-StoredProcedure',
                            'Add-Synonym',
                            'Add-Table',
                            'Add-Trigger',
                            'Add-UniqueKey',
                            'Add-UserDefinedFunction',
                            'Add-View',
                            'Disable-Constraint',
                            'Enable-Constraint',
                            'Get-Migration',
                            'Get-RivetConfig',
                            'Invoke-Ddl',
                            'Invoke-Rivet',
                            'Invoke-SqlScript',
                            'Merge-Migration',
                            'New-BigIntColumn',
                            'New-BinaryColumn',
                            'New-BitColumn',
                            'New-CharColumn',
                            'New-Column',
                            'New-DateColumn',
                            'New-DateTime2Column',
                            'New-DateTimeColumn',
                            'New-DateTimeOffsetColumn',
                            'New-DecimalColumn',
                            'New-FloatColumn',
                            'New-HierarchyIDColumn',
                            'New-IntColumn',
                            'New-MoneyColumn',
                            'New-NCharColumn',
                            'New-NVarCharColumn',
                            'New-RealColumn',
                            'New-RowVersionColumn',
                            'New-SmallDateTimeColumn',
                            'New-SmallIntColumn',
                            'New-SmallMoneyColumn',
                            'New-SqlVariantColumn',
                            'New-TimeColumn',
                            'New-TinyIntColumn',
                            'New-UniqueIdentifierColumn',
                            'New-VarBinaryColumn',
                            'New-VarCharColumn',
                            'New-XmlColumn',
                            'Remove-CheckConstraint',
                            'Remove-DataType',
                            'Remove-DefaultConstraint',
                            'Remove-Description',
                            'Remove-ExtendedProperty',
                            'Remove-ForeignKey',
                            'Remove-Index',
                            'Remove-PrimaryKey',
                            'Remove-Row',
                            'Remove-RowGuidCol',
                            'Remove-Schema',
                            'Remove-StoredProcedure',
                            'Remove-Synonym',
                            'Remove-Table',
                            'Remove-Trigger',
                            'Remove-UniqueKey',
                            'Remove-UserDefinedFunction',
                            'Remove-View',
                            'Rename-Column',
                            'Rename-DataType',
                            'Rename-Index',
                            'Rename-Object',
                            'Stop-Migration',
                            'Update-CodeObjectMetadata',
                            'Update-Description',
                            'Update-ExtendedProperty',
                            'Update-Row',
                            'Update-StoredProcedure',
                            'Update-Table',
                            'Update-Trigger',
                            'Update-UserDefinedFunction',
                            'Update-View',
                            '*' # For plug-ins.
                         )

    # Cmdlets to export from this module
    CmdletsToExport = '*'

    # Variables to export from this module
    VariablesToExport = ''

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
            Tags = @('sql-server','evolutionary-database','database','migrations')

            # A URL to the license for this module.
            LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'

            # A URL to the main website for this project.
            ProjectUri = 'http://get-rivet.org'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = @'
* Adding support for running Rivet under Windows PowerShell 5.1 and PowerShell Core.
* You can now specify the order Rivet should apply migrations to multiple databases with the "DatabaseOrder" setting in your rivet.json file. It should be set to a list of databases and Rivet will apply migrations to databases in that order. See `help about_Rivet_Configuration` for more information.
'@
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
