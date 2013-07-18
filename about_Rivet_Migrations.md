# Name

about_Rivet_migrations
    
# Synopsis

Explains how to write Rivet migrations.
    
# Description

## Variables
  
You can use the following special variables in your `Push-Migration` and `Pop-Migration` functions:

 * `$DBScriptRoot`: the path to the script root directory of the database you're migrating.

## Tables
  
The following functions are available for managing tables:
 
 * Add-Table
 * Remove-Table 
    
The `Add-Column`'s  `Column` parameter is a script block that should return columns as column objects, e.g.,

    Add-Table Customer {
        New-Column 'ID' -Int -Identity
        New-Column 'Name' -Varchar -Unicode -NotNull
        New-Column 'ZipCode' -Int -NotNull
    }

## Columns

 * Add-Column
 * Remove-Column

## Code Objects
  
The following functions will remove objects of the specified type.  Use the `IfExists` flag to only delete the object if it exists.

 * Remove-StoredProcedure 
 * Remove-UserDefinedFunction 
 * Remove-View 

## Executing Code Object Scripts

Stored procedures, user-defined functions, views and other database objects are usually stored in external script files, which are executed against the database to create/update the object.  In some cases, it can take a long time to run all your code object scripts, so it can be useful to included updated/new scripts in a migration.  Rivet assumes scripts for object types are stored under `$DBScriptRoot` in directories with the following names: 

 * Stored Procedures
 * User-Defined Functions
 * Views

Under these directories, scripts should be stored per-object in files named after the object.  For example, if you have stored procedure `InsertIntoFoo`, it should be saved in `$DBScriptRoot\Stored Procedures\InsertIntoFoo.sql`.  If your script is in a schema other than `dbo`, the file's name should be prefixed with the schema.  For example, if your stored procedure `InsertIntoFoo` is in the `bar` schema, it should be saved in `$DBScriptRoot\Stored Procedures\bar.InsertIntoFoo.sql`.

Use these functions to run the script for a code object:

    Set-StoredProcedure -Name <string> [-Schema <string>]
    
    Set-UserDefinedFunction -Name <string> [-Schema <string>]
    
    Set-View -Name <string> [-Schema <string>]

To execute an arbitrary SQL script, use `Invoke-SqlScript`:

    Invoke-SqlScript -Path <string>

If the `Path` argument is a relative path, the full path to the SQL script is resolved from the directory of the migration script.  For example, if your database's migrations directory is `C:\Projects\Rivet\Databases\RivetTest\Migrations`, this path:

    Invoke-SqlScript -Path ..\Miscellaneous\CreateDesertedIsland.sql

would resolve to `C:\Projects\Rivet\Databases\RivetTest\Miscellaneous\CreatedDesertedIsland.sql`.

## Raw SQL

When none of the functions above will do the trick, use the `Invoke-Query` function to execute raw SQL:

    Invoke-Query -Query <string>

You can use a PowerShell here string for longer queries and so you don't have to escape quotes:

    Invoke-Query -Query @'
        -- SQL goes here.  You don't have to escape single quotes.
    '@  # '@ must be the first two characters on the line to close the string.

# SEE ALSO
    Add-Column
    Add-Description
    Add-Table
    Invoke-Query
    Invoke-SqlScript
    New-Column
    Remove-Column
    Remove-Description
    Remove-StoredProcedure
    Remove-Table
    Remove-UserDefinedFunction
    Remove-View
    Set-StoredProcedure
    Set-UserDefinedFunction
    Set-View
    Update-Description
