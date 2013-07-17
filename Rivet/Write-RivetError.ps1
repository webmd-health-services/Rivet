
function Write-RivetError
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The error message to display.
        $Message,
        
        [Parameter(Mandatory=$true)]
        [Exception]
        # The exception being reported.
        $Exception,
        
        [Parameter(Mandatory=$true)]
        [Management.Automation.CallStackFrame[]]
        # The call stack to report.
        $CallStack
    )
    
    $firstException = $_.Exception
    while( $firstException.InnerException )
    {
        $firstException = $firstException.InnerException
    }
    
    $callStackLines = $CallStack |
                    Select-Object -ExpandProperty InvocationInfo |
                    Where-Object { $_.ScriptName } |
                    ForEach-Object { "{0}:{1}: {2}" -f $_.ScriptName,$_.ScriptLineNumber,$_.Line.Trim()  }
    
    $callStackLines = $callStackLines -join "`n "
        
    Write-Error ("{0}: {1}`n{2}" -f $Message,$firstException.Message,$callStackLines)

}