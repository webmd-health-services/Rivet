# Name

about_Rivet_Configuration

# Synopsis

Explains the Rivet configuration file.

# Description

## Overview

Rivet pulls the many settings it needs from a JSON configuration file called `rivet.json`.  By default, Rivet will look in the curret directory for the `rivet.json` file.  The `rivet.ps1` script allows you to pass in the path to your own configuration file.

The `rivet.json` file is written in JSON, because I don't like XML.  Make sure all `\` (i.e. backspace) characters get escaped (e.g. `\\`).  Comments are not allowed.

All non-absolute paths in the `rivet.json` file are resolved as relative to the file itself.  For example, if a setting's path is `Databases`, and the `rivet.json` file is in the `C:\Projects\Rivet\Test` directory, the setting's value will be resolved to `C:\Projects\Rivet\Test\Databases`.

## Available Options

The following configuration options are available:

### CommandTimeout

The amount of time, in seconds, to wait for a command to complete.  The default is 30 seconds.

### ConnectionTimeout

The amount of time, in seconds, to wait for a database connection to open.  The default is 15 seconds.
    
### DatabasesRoot

Rivet assumes a database's migration scripts are stored together.  in `$DatabasesRoot\$DatabaseName\Migrations`.  So, `$DatabasesRoot` should point to the directory which contains the directories for each database.  For example, given this directory structure:

    * rivet.json
    + Databases
      + Rivet
        + Migrations
      + RivetTest
        + Migrations

You can see directories for the `Rivet` and `RivetTest` databases under the `Databases` directory.  So, you'll set the `DatabasesRoot` setting to `Databases`.

Rivet assumes there is a one-to-one mapping between the directories under `DatabasesRoot` and a database on the SQL Server.  If this is not the case, and you'd like to exclude/ignore a directory under `DatabasesRoot`, use the `IgnoreDatabases` setting.

### IgnoreDatabases

A list of database names to ignore/exclude from the Rivet.  This is useful if you have a directory  under `DatabasesRoot` that doesn't contain a database's scripts.  Wildcards are allowed, e.g. `Shared*` would exclude all directories under `DatabasesRoot` that begin with the word `Shared`.

### SqlServerName

The name of the SQL Server to connect to.

## Examples

### Example 1

The simplest configuration file looks like this:

    {
        SqlServerName: '.\\Rivet',
        DatabasesRoot: 'Databases'
    }

This configuration file will cause Rivet to connect to the `.\Rivet` SQL Server, and load database scripts from the `Databases` directory where the `rivet.json` file is located.

### Example 2

This example demonstrates how to use all the configuration options:

    {
        SqlServerName: '.\Rivet',
        DatabasesRoot: 'Databases',
        ConnectionTimeout: 5,
        CommandTimeout: 300,
        IgnoreDatabases: [ 'Shared' ]
    }

This configuration file will:

 * connect to the local `.\Rivet` SQL Server instance
 * load database scripts from the `Databases` directory (which would be in the same directory as the `rivet.json` file)
 * shorten the connection timeout to 5 seconds
 * increase the command timeout to 5 minutes
 * not add the `Shared` database to the list of databases to manage (i.e. it will ignore the `$Databases\Shared` directory)

# See Also

rivet.ps1
