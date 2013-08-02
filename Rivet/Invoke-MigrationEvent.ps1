
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
    
    ## Function Declarations

    function Get-FunctionsInFile($testScript)
    {
        Write-Verbose "Loading test script '$testScript'."
        $testScriptContent = Get-Content "$testScript"
        if( -not $testScriptContent )
        {
            return @()
        }

        $errors = [Management.Automation.PSParseError[]] @()
        $tokens = [System.Management.Automation.PsParser]::Tokenize( $testScriptContent, [ref] $errors )
        if( $errors -ne $null -and $errors.Count -gt 0 )
        {
            Write-Error "Found $($errors.count) error(s) parsing '$testScript'."
            Exit-Pest -1 
        }
    
        Write-Verbose "Found $($tokens.Count) tokens in '$testScript'."
    
        $functions = New-Object System.Collections.ArrayList
        $atFunction = $false
        for( $idx = 0; $idx -lt $tokens.Count; ++$idx )
        {
            $token = $tokens[$idx]
            if( $token.Type -eq 'Keyword'-and $token.Content -eq 'Function' )
            {
                $atFunction = $true
            }
        
            if( $atFunction -and $token.Type -eq 'CommandArgument' -and $token.Content -ne '' )
            {
                Write-Verbose "Found function '$($token.Content).'"
                [void] $functions.Add( $token.Content )
                $atFunction = $false
            }
        }
    
        return $functions.ToArray()
    }

    ## Skip if Schema is in rivet

    if ($EventArg."SchemaName" -eq "rivet")
    {
        return
    }

    $scriptName = ('Complete-{0}.ps1' -f $Name)
    $functionName = ('Complete-{0}' -f $Name)
    $eventScript = Join-Path $settings.PluginsRoot $scriptName

    ## Test that the script exists, if not exit

    if ((Test-Path $eventScript) -eq $False)
    {
        return
    }
   
    ## Parse and Error Check

    if ($eventScript)
    {
        $functions = @(Get-FunctionsInFile $eventScript)
        
        ## Test for case of other than one function in file
        if ($functions.Count -ne 1)
        {
            $functionCountErrorMsg = "`nSyntax Error: {0}`nNumber of Functions: {1}" -f $scriptName, $functions.Count
            Write-Warning $functionCountErrorMsg 
            $ExceptionMsg = 'Function Count in Migration Event is {0}' -f $functions.Count
            throw (New-Object ApplicationException $ExceptionMsg)
        }

        ## Test for wrong function name in file
        if ($functions -ne $functionName)
        {
            $functionNameErrorMsg = "`nSyntax Error: {0}`nFunction Name: {1}" -f $scriptName, $functions[0]
            Write-Warning $functionNameErrorMsg
            $ExceptionMsg = 'Invalid Event Name: {0}' -f $functions[0]
            throw (New-Object ApplicationException $ExceptionMsg)
        }
    }

    ## Execute Script

    if (Test-Path -Path $eventScript -PathType Leaf)
    {
        try 
        {
            . $eventScript
            & ('Complete-{0}' -f $Name) -TableName $EventArg."TableName" -SchemaName $EventArg."SchemaName"
        }
        catch #Catches Syntax Error
        {
            $ex = $_.Exception
            $syntaxErrorMsg = "`nSyntax Error: {0}`n{1}" -f $scriptName, $ex.Message
            Write-Warning $syntaxErrorMsg
            throw (New-Object ApplicationException $syntaxErrorMsg)
        }
        
        Remove-Item ('function:\Complete-{0}' -f $Name)
    }
   

}