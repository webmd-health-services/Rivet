# Name

about\_Rivet\_Configuration

# Synopsis

Explains the Rivet configuration file.

# Description

## Overview

Rivet pulls the many settings it needs from a JSON configuration file called `rivet.json`.  By default, Rivet will look in the current directory for the `rivet.json` file.  The `rivet.ps1` script allows you to pass in the path to your own configuration file.

The `rivet.json` file is written in JSON, because I don't like XML.  Make sure all `\` (i.e. backspace) characters get escaped (e.g. `\\`).  Comments are not allowed.

All non-absolute paths in the `rivet.json` file are resolved as relative to the file itself.  For example, if a setting's path is `Databases`, and the `rivet.json` file is in the `C:\Projects\Rivet\Test` directory, the setting's value will be resolved to `C:\Projects\Rivet\Test\Databases`.

## Environments

You will most likely have many environments where Rivet will run.  At a minimum, each environment will have a different SQL Server instance.  To support multiple environments, the `rivet.json` file uses a special `Environments` setting, which is a hash of environments, where the key is the environment's name and the value is another hash of settings for that environment. These environment settings override the base/default settings.  If an environment doesn't specify a setting, the base/default setting is used.

    {
        SqlServerName: '.\Rivet',
        DatabasesRoot: 'Databases',
        Environments: 
        {
            Production:
            {
                SqlServerName: 'proddb\Rivet',
            }
        }
    }

In this example, we've defined a `Production` environment which overrides the `SqlServerName` setting.

## Settings

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

### Environments

A hash of environments, where they key is the environment's name, and the value is another hash of settings for that environment. These environment settings override the base/default settings.  If an environment doesn't specify a setting, the base/default setting is used.

### IgnoreDatabases

A list of database names to ignore/exclude from the Rivet.  This is useful if you have a directory  under `DatabasesRoot` that doesn't contain a database's scripts.  Wildcards are allowed, e.g. `Shared*` would exclude all directories under `DatabasesRoot` that begin with the word `Shared`.

### PluginsRoot

This should point to the directory which contains the directory for which plugins should be stored.  For example, given this directory structure:

	* rivet.json
	+Databases
	+Plugins

PluginsRoot should point to the "Plugins" directory

### SqlServerName

The name of the SQL Server to connect to.

## Examples

### Example 1

    {
        SqlServerName: '.\\Rivet',
        DatabasesRoot: 'Databases'
    }

This example demonstrates the simplest configuration file. This configuration file will cause Rivet to connect to the `.\Rivet` SQL Server, and load database scripts from the `Databases` directory where the `rivet.json` file is located.

### Example 2

    {
        SqlServerName: '.\Rivet',
        DatabasesRoot: 'Databases',
        ConnectionTimeout: 5,
        CommandTimeout: 300,
        IgnoreDatabases: [ 'Shared' ]
    }

This example demonstrates how to use all the configuration options.  This configuration file will:

 * connect to the local `.\Rivet` SQL Server instance
 * load database scripts from the `Databases` directory (which would be in the same directory as the `rivet.json` file)
 * shorten the connection timeout to 5 seconds
 * increase the command timeout to 5 minutes
 * not add the `Shared` database to the list of databases to manage (i.e. it will ignore the `$Databases\Shared` directory)
 
### Example 3

    {
        SqlServerName: '.\Rivet',
        DatabasesRoot: 'Databases',
        Environments: 
        {
            UAT:
            {
                SqlServerName: 'uatdb\Rivet',
                IgnoreDatabases: [ 'Preview' ],
                CommandTimeout: 300
            },
            Production:
            {
                SqlServerName: 'proddb\Rivet',
                IgnoreDatabases: [ 'Preview' ],
                CommandTimeout: 600
            }
        }
    }

This example demonstrates how to create and use environment-specific settings.  

# See Also

rivet.ps1
