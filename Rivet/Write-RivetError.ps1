
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
        $ErrorID,

        [Parameter()]
        [string]
        # Query, if any
        $Query
    )
    
    $firstException = $_.Exception
    while( $firstException.InnerException )
    {
        $firstException = $firstException.InnerException
    }
    
    if (-not $Query)
    {
        $Query = "None"
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
QUERY:
======
{5}
`v
ERROR-INFO:
===========
"@ -f $Connection.DataSource,$Connection.Database,$Message,$firstException.Message,$CallStack, $Query) -ErrorID $ErrorID -Category $CategoryInfo 

}