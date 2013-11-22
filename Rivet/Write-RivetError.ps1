
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
[{0}].[{1}] {2}: {3}
  {4}
 
QUERY
=====
{5}
 
"@ -f $Connection.DataSource,$Connection.Database,$Message,$firstException.Message,($CallStack -replace "`n","`n  "), $Query) -ErrorID $ErrorID -Category $CategoryInfo 

}