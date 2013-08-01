
function Invoke-MigrationEvent
{
    <#
    .SYNOPSIS
    Fires a migration event.

    .DESCRIPTION
    Migration events can be used to perform standard actions before/after certain migrating.  Currently, there is only one event: Complete-AddTable.

    You may do whatever you want in your event handler: write a message, perform additional migrations, etc. Typically, you would use the handler to perform some kind of global migration, e.g. adding `CreatedAt` and `UpdatedAt` columns to all your tables.

    To subscribe to an event, create a PowerShell function with the name of the event.  Save that function in a script file *with the same name*, and set the `PluginsPath` setting to point to the directory where you saved the script.

    ## Events

    ### Complete-AddTable

    This event gets called at the end of the Add-Table migration.  Its signature should look like this:

         Complete-AddTable [-TableName <string>] [-SchemaName <string>]

    .LINK
    about_Rivet_Configuration

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the event.  Controls which event handler is called.
        $Name,

        [Parameter(Mandatory=$true)]
        [Switch]
        # Calls the `Complete` event.
        $OnComplete,

        [Parameter()]
        [hashtable]
        $EventArg
    )

    
}