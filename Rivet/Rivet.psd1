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
    ModuleVersion = '0.23.1'

    # ID used to uniquely identify this module
    GUID = '8af34b47-259b-4630-a945-75d38c33b94d'

    # Author of this module
    Author = 'WebMD Health Services'

    # Company or vendor of this module
    CompanyName = 'WebMD Health Services'

    CompatiblePSEditions = @( 'Desktop', 'Core' )

    # Copyright statement for this module
    Copyright = 'Copyright 2013 - 2019 WebMD Health Services.'

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
        # Functions
        # TODO: only `Invoke-Rivet` should be exported. These functions should be made private and a parameter set
        # added to `Invoke-Rivet` that calls them:
        #
        # TODO: should be made private and exposed with a `rivet -Export` command.
        'Export-Migration',
        # TODO: should be made private and exposed with a `rivet -Get` command.
        'Get-Migration',
        # TODO: should be made private and exposed with a `rivet -Configuration` command (maybe find a better way).
        'Get-RivetConfig',
        'Import-RivetPlugin',
        'Invoke-Rivet',
        'Invoke-RivetPlugin',
        # TODO: Should be made private and exposed with a `rivet -Get -Merge` command.
        'Merge-Migration',
        # TODO: should be made private. Already exposed as `rivet -New` command.
        'New-Migration',

        # Operations
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
        'Invoke-Ddl',
        'Invoke-SqlScript',
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

        # Columns
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
        'New-RivetSession',
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
        'New-XmlColumn'
    )

    # Cmdlets to export from this module
    CmdletsToExport = @(
        'Add-Index'
    )

    # Variables to export from this module
    VariablesToExport = ''

    # Aliases to export from this module
    AliasesToExport = @(
        'BigInt',
        'Binary',
        'Bit',
        'Char',
        'Date',
        'DateTime',
        'DateTime2',
        'DateTimeOffset',
        'Decimal',
        'Disable-CheckConstraint',
        'Enable-CheckConstraint',
        'Float',
        'HierarchyID',
        'Int',
        'Money',
        'NChar',
        'New-NumericColumn',
        'Numeric',
        'NVarChar',
        'Real',
        'rivet',
        'RowVersion',
        'SmallDateTime',
        'SmallInt',
        'SmallMoney',
        'SqlVariant',
        'Time',
        'TinyInt',
        'UniqueIdentifier',
        'VarBinary',
        'VarChar',
        'Xml'
    )

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

            # The module's prerelease label. Modified by build process when publishing a prerelease version.
            Prerelease = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/webmd-health-services/Rivet/blob/main/CHANGELOG.md'
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
