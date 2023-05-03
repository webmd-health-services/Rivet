<!--markdownlint-disable MD012 no-multiple-blanks -->
<!--markdownlint-disable MD024 no-duplicate-heading/no-duplicate-header -->

# Rivet Changelog

## 0.20.0

> Released 3 May 2023

### Added

* `New-RivetSession` function for creating a Rivet session. A `Rivet_Session` is the object used by Rivet to keep track
of current state.
* `Connect-RivetSession` function for connecting to the databases in a Rivet session.

### Changed

* Rivet internals no longer use global variables for managing connections and current state.
* Default migration output now quotes SQL Server names and database names with `[]`.
* Verbose output now shows query parameter names and values.

### Fixed

* Shows too many errors.
* `Remove-ForeignKey` prompts for `TableName` and `ReferencesTableName` arguments.
* Creating a new migration also creates an unused schema.ps1 file and writes a warning that it should be added to source
control


## 0.19.0

> Released 3 Apr 2023

* `Checkpoint-Migration` will no longer delete migration scripts that have been pushed to the database. Instead it
  will now export rows from the `rivet.Migrations` table and include them in the `schema.ps1` file.
* Added an `InitializeSchema` switch to the `Invoke-Rivet` script that is used to initialize database(s) with the
  `schema.ps1` file that is generated from `Checkpoint-Migration`.


## 0.18.0

> Released 22 Feb 2023

* Fixed: Rivet doesn't use the CommandTimeout property in rivet.json configuration file.
* `Export-Migration` will now allow references to objects in databases that have been applied before it.
* The `DatabaseOrder` setting in the rivet.json file has been removed in favor of a new `Databases` property that should
be the ordered-list of databases to migrate.
* `Export-Migration` will now include extended properties on schemas, views, and view columns.


## 0.17.0

> Released 26 Oct 2022

### Changes

* When initializing a database, Rivet now runs the migrations found in the schema.ps1 file, which contains the baseline
database schema upon which all migrations should be applied. You can use the `Checkpoint-Migration` function to create
a baseline `schema.ps1` file for your database(s).


## 0.16.0

> Released 18 Oct 2022

* Updated `Checkpoint-Migration` function:

* The `schema.ps1` file generated from `Checkpoint-Migration` is saved to the Migrations directory of each database
that is being checkpointed.
* Only migrations that have been applied to the database will be exported to the `schema.ps1` file.
* Migrations that have been checkpointed will be removed from the Migrations directory.


## 0.15.0

> Released 11 Oct 2022

* Added `Checkpoint-Migration` function that checkpoints the current state of the database so that it can be re-created.


## 0.14.0

> Released 29 Aug 2022

* Added an `AfterMigrationLoad` Rivet event that occurs after all operations in a migration have been applied, but
before the transaction has been commited. Use this event for any validations that require a fully loaded migration.


## 0.13.0

> Released 23 Jun 2022

* Added a `Reset` switch to `rivet.ps1` that will drop the database(s) for the current environment when given.


## 0.12.0

> Released 5 May 2020

### Upgrade Instructions

* This version of Rivet is backwards-incompatible. It changes the way plug-ins work. In order to upgrade to this
version, you'll need to update your plugins and your rivet.json file.

1. Package your plugins into a PowerShell module. Make sure your plug-in functions are exported by your module.
2. Add the attribute `[Rivet.Plugin([Rivet.Event]::BeforeOperationLoad)]` to any existing `Start-MigrationOperation`
functions.
3. Add the attribute `[Rivet.Plugin([Rivet.Event]::AfterOperationLoad)]` to any existing `Complete-MigrationOperation`
functions.
4. Change the `PluginsRoot` setting in your rivet.json file to `PluginPaths`. Change its value to the path to the module
you created in step 1. Rivet will import the module into the global scope for you. Or, if you want to import the
module, set the `PluginModules` property to a list of module names that contain the plug-ins to use.

* See `about_Rivet_Plugins` for more information.

### Changes

* Created `Export-Migration` function for exporting database objects as Rivet migrations.
* Rivet can now add XML columns that don't have schema associated with them.
* `New-Column` can now be used to create columns on tables that have custom size specifications, are rowguidcol, are
identities, custom collations, and are file stream.
* Fixed: `Merge-Migration` doesn't merge `Add-RowGuidCol` and `Remove-RowGuidCol` operations into
`Add-Table`/`Update-Table` operations.
* Breaking Change: Rivet plug-ins must now be packaged as/in PowerShell modules. The `PluginsRoot` configuration option
has been renamed to `PluginPaths` and should be a list of paths were Rivet can find the PowerShell modules containing
your plug-ins. These paths are imported using the `Import-Module` command. See `about_Rivet_Plugins` for more
information.
* The `PluginsPath` (fka `PluginsRoot`) configuration setting is now allowed to have wildcards.
* Completely re-architected how `Merge-Migration` merges migrations together. This fixed a lot of bugs where many
operations were not merging correctly.
* The Convert-Migration.ps1 sample script no longer include a header for all migrations that affected an operation,
since Rivet no longer exposes this information. Instead, it only adds an author header for the migration an operation
ends up in.
* The `Remove-DefaultConstraint` operation's `ColumnName` parameter is now required. When merging operations, Rivet needs
to know what column a default expression operates on. You'll get a warning if it isn't provided. In a future version of
Rivet, this parameter will be made mandatory.
* Default constraint names are now required. You must pass a constraint name to the Add-DefaultConstraint operator's
Name parameter and to the DefaultConstraintName parameter on any column definition that has a default value.
* Performance improvement: Rivet now only queries once for the state of all applied migrations instead of querying for
every migration.
* Performance improvement: Rivet only reads migration files that haven't been applied to a database. This should help
with backwards-compatability. If Rivet's API changes only migrations you want to push/pop will need to get updated to
match the new API.
* Unique key constraint names are now required. You must pass a constraint name to the Add-UniqueKey operation's Name
parameter.
* Primary key constraint names are now required. You must pass a constraint name to the Add-PrimaryKey operation's Name
parameter.
* Foreign key constraint names are now required. You must pass a constraint name to the Add-ForeignKey operation's Name
parameter.
* Index names are now required. You must pass an index name to the Add-Index operation's Name parameter.
* Fixed: Get-Migration and Get-MigrationFile don't properly exclude migrations in some situations.
* Fixed: the idempotent queries for renaming a data type and index don't work.


## 0.9.1

> Released 27 Mar 2020

* Fixed: `Merge-Migration` fails in certain situations if a migration contains a `Rename-Column` operation.


## 0.9.0

> Released 27 Nov 2018

* Adding support for running Rivet under Windows PowerShell 5.1 and PowerShell Core.
* You can now specify the order Rivet should apply migrations to multiple databases with the "DatabaseOrder" setting in
your rivet.json file. It should be set to a list of databases and Rivet will apply migrations to databases in that
order. See `help about_Rivet_Configuration` for more information.


## 0.8.1

> Released 26 Nov 2016

* Removing a custom operation that isn't part of core Rivet.


## 0.8.0

> Released 25 Nov 2016

### Enhancements

* Created `Merge-Migration` function for creating cumulative, roll up migrations.


## 0.7.0

### Enhancements

* Fixed: `Add-Index` operation times out when creating new indexes on large table. Added a `Timeout` parameter to
control how long to wait for an operation to finish.
* `Add-Index` re-implemented as a C# cmdlet.


## 0.6.1

### Bug Fixes

* `Rename-Column`, `Rename-DataType`, `Rename-Index`, and `Rename-Object` operations didn't properly quote schema and
object names.


## 0.6.0

### Enhancements

* Improving verbose output to be more recognizable and include query timings.
* `Convert-Migration.ps1` extra script now puts triggers, constraints, foreign keys, and types into separate files.
* `New-Migration` now increments timestamp if a migration with the same timestamp already exists instead of sleeping
for half a second.
* Added format for `Rivet.Migration` objects so they display nicely when running migrations.
* Adding Rivet about help topics.
* Created `Add-RowGuidCol` operation for adding the `rowguidcol` property to a column.
* Created `Remove-RowGuidCol` operation for removing the `rowguidcol` property from a column.
* Created `Stop-Migration` operation for preventing a migration from getting popped/reversed.
* Migrations missing Push-Migration/Pop-Migration functions are no longer allowed and will fail when pushed/popped.
* Migrations with empty Push-Migration/Pop-Migration functions are no longer allowed and will fail when pushed/popped.
* Obsoleted the parameter sets of the `Remove-CheckConstraint`, `Remove-DefaulConstraint`, `Remove-ForeignKey`,
`Remove-Index`, `Remove-PrimaryKey`, and `Remove-UniqueKey` operations that use an inferred constraint/index name.
These operations now expect the name of the constraint/index to drop with the `Name` parameter.
* Improved object model so that customizing index/constraint names is easier.
* Added `about_Rivet_Cookbook` help topic to showing how to customize index/constraint names.
* Updated and improved the `about_Rivet_Plugins` help topic.
* Obsoleted the `Enable-ForeignKey` and `Disable-ForeignKey` operations. Use the `Enable-Constraint` and
`Disable-Constraint` operations instead.
* Renamed the `Enable-CheckConstraint` operation to `Enable-Constraint`, with a backwards-compatible alias.
* Renamed the `Disable-CheckConstraint` operation to `Disable-Constraint`, with a backwards-compatible alias.
* You can now push, pop, or create multiple migrations at once (i.e. `rivet.ps1`'s `Name` parameter now accepts
multiple names, IDs, or file names).
* Plug-ins now get passed a `Rivet.Migration` object for the operation being processed.
* Rivet now supports writing custom operations.

### Bug Fixes

* Results from `Invoke-SqlScript` operations cause silent error when formatted as a table.
* Path to rivet.json file not showing in an error message when using implicit path.


## 0.5.1

### Enhancements

* Improving `WhatIf` support: some actions that shouldn't be conditional now ignore `WhatIf` flag.
* Invoke-SqlScript operation no longer splits script into batches, since that is now handled internally when executing
all operations.
* Improving verbose output: adding a message for each already-applied migration.

### Bug Fixes

* Get-Migration fails when run from Convert-Migration: it doesn't know the path to use to load migrations from.


## 0.5.0

### Enhancements

* The Add-Schema operation is now idempotent.
* Removed all Write-Host output.
* Rivet now returns OperationResult objects for each query executed by an operation. Default format included (i.e. this
output replaces the old Write-Host output).
* Renamed `Invoke-Query` operation to `Invoke-Ddl`.
* Renamed `Rivet.Operations.RawQueryOperation` to `Rivet.Operations.RawDdlOperation`.
* Moved `Rivet.Operations.Operation` object into `Rivet` namespace; so full type name is now `Rivet.Operation`.


## 0.4.0

### Enhancements

* NOCHECK parameter has been added to `Add-ForeignKey` and `Add-CheckConstraint` operations
* `Disable-CheckConstraint` and `Enable-CheckConstraint` functions have been added.
* `Disable-ForeignKey` and `Enable-ForeignKey` functions have been added.

### Bug Fixes

* Convert-Migration.ps1 generates incorrect SQL if a migration removes then re-adds a column.


## 0.3.3

* Improved error message when failing to connect to SQL Server.
* `Add-Index` operation now supports INCLUDE clause.


## 0.3.2

### Bug Fixes

* `Invoke-SqlScript` fails when `NonQuery` switch is used.


## 0.3.1

### Enhancements

* `Get-RivetConfig` is now a publicly exposed function.  Use this method to parse a Rivet JSON configuration file.
It returns a `Rivet.Configuration.Configuration` object.


## 0.3.0

### Enhancements

* `Get-Migration` now returns a `Rivet.Operations.ScriptFileOperation` object instead of a
`Rivet.Operations.RawQueryOperation` for `Invoke-SqlQuery` operations.

### Bug Fixes

* `Invoke-SqlScript` ignoring `CommandTimeout` parameter.
* `Invoke-SqlScript` didn't rollback migration if the script file was not found.
* `Get-Migration` fails if a migration doesn't contain a `Push-Migration` or `Pop-Migration` function.
* `Get-Migratoin` duplicates output of previous migration if a migration is missing a `Push-Migration` or
`Pop-Migration` function.


## 0.2.1

### Bug Fixes

* If a database has multipe target databases and no migrations directory, Rivet stops after the first target database.


## 0.2.0

* Databases are now created if they don't exist.
* A single database connection is now re-used when migrating multiple databases, instead of establishing a new
connection for each database.
* A database's migrations can now be applied to multiple target databases via the new `TargetDatabases` configuration
option. See `about_Rivet_Configuration` for more information.
* Rivet now updates its internal objects using migrations (i.e. it is now self-migrating). It uses (and reserves)
migration IDs below 01000000000000. If you have migrations with these IDs, you'll need to give them new IDs and update
IDs in any rivet.Migrations table that uses that ID.
* Migration name maximum length increased to 241 characters (the theoretical maximum allowed by Windows).
