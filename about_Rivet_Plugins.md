TOPIC
    about_Rivet_Plugins

SHORT DESCRIPTION
    Explains the Rivet Plugin system

LONG DESCRIPTION

    Plugins in Rivet allow users to configure custom tasks that are automatically executed after certain functions in the Rivet migration task.  
    
    For example, the custom task can be to automatically generate administrative columns to all new tables.  
    
    In the current implementation, that only Rivet function that is supported is `Add-Table`.  `Add-Table` will call `Invoke-MigrationEvent` at the end.  `Invoke-MigrationEvent` will check that there is a proper script file in the plugins directory.  If there is, the migration event will be executed.
    
    The plugins directory is defined in the `rivet.json` file.  See `about_Rivet_Configuration` for more details.
    
    A proper script file must contains only one function of a specific name.  The function name should be in the powershell standard Verb-Noun format for functions.  The verb must be "Complete-" and the noun is the rivet function.  In the current implementation the `Add-Table` function will look for `Complete-AddTable` in the migration event script.  An incorrect name will fail the script.
    
    If there is a syntax error in the migration event script, or if the migration event script does not follow the rules above, an exception will be thrown and the main migration itself will not be applied.
    
    If there simply does not exist a script file at all in the plugins directory, the migration will be applied and no migration event will be applied post migration.
    
SEE ALSO
    about_Rivet  
    about_Rivet_Configuration  
    about_Rivet_Intellisense  
    about_Rivet_Migrations  
 

