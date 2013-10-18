
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
        [string]
        # The call stack to report.
        $CallStack,

        [Parameter(Mandatory=$true)]
        [string]
        # The Category Info
        $CategoryInfo,

        [Parameter(Mandatory=$true)]
        [string]
        # The Fully Qualified Error ID
        $ErrorID
    )
    
    $firstException = $_.Exception
    while( $firstException.InnerException )
    {
        $firstException = $firstException.InnerException
    }
        
    Write-Error (@"
`v
MESSAGE:
========
[{0}].[{1}] {2}: {3}
`v
STACKTRACE:
===========
{4}
`v
ERROR-INFO:
===========
"@ -f $Connection.DataSource,$Connection.Database,$Message,$firstException.Message,$CallStack) -ErrorID $ErrorID -Category $CategoryInfo

}