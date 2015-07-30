TOPIC
    about_Rivet_Intellisense

SHORT DESCRIPTION
    Explains how to get Intellisense when writing Rivet migrations.

LONG DESCRIPTION

    In order to get Intellisense when writing migrations, you'll need to have PowerShell ***3*** installed, and use the PowerShell Integrated Scripting Environment (i.e. ISE).  You should be able to open a migration in the ISE by right-clicking it and choosing "Edit".  
    
    Once you've got a migration open in the ISE, you'll want to import the Rivet module.  Use the `Import-Rivet.ps1` script:
    
        PS> Import-Rivet.ps1
    
    Make sure you use the path to Rivet in your environment.
    
    Once you've imported Rivet, you can get a list of available migrations by running this command:
    
        PS> Get-Command -Module Rivet -CommandType Function
    