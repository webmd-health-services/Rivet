
function Resolve-ObjectScriptPath
{
    <#
    .SYNOPSIS
    Resolves the path to a SQL object script.
    
    .DESCRIPTION
    All scripts are expected to live under a database-specific parent directory in well-known directories by type name.  Each script should be stored by object name, prefixed with the schema if it isn't `dbo`.  For example:
    
     * Stored procedure `dbo.MySproc` is expected to be in `$Database\Stored Procedures\MySproc.sql`.
     * Stored procedure `pstep.MySproc` is expected to be in `$Database\Stored Procedures\pstep.MySproc.sql`.
    
    .EXAMPLE
    Resolve-ObjectScriptPath -StoredProcedure -Name MySproc
    
    Returns the path to the `dbo.MySproc` stored procedure's script file.
    
    .EXAMPLE
    Resolve-ObjectScriptPath -StoredProcedure -Name MySproc -Schema pstep
    
    Returns the path to the `pstep.MySproc` stored procedure's script file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName='Stored Procedures')]
        [Switch]
        $StoredProcedure,
        
        [Parameter(ParameterSetName='User-Defined Functions')]
        [Switch]
        $UserDefinedFunction,
        
        [Parameter(ParameterSetName='Views')]
        [Switch]
        $View,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the object.
        $Name,
        
        [Parameter()]
        [string]
        # The schema of the object.  Defaults to `dbo`.
        $Schema = 'dbo'
    )
    
    $objectTypeDirName = $pscmdlet.ParameterSetName
    
    $objectDirPath = Join-Path $Connection.ScriptsPath $objectTypeDirName
    if( -not (Test-Path -Path $objectDirPath -PathType Container) )
    {
        throw ('{0} script directory {1} not found.' -f $objectTypeDirName,$objectDirPath)
    }
    
    $objectFileName = '{0}.{1}.sql' -f $Schema,$Name
    $objectFileFullName = Join-Path $objectDirPath $objectFileName
    if( -not (Test-Path -Path $objectFileFullName -PathType Leaf) )
    {
        $objectFileName = $objectFileName -replace '^dbo\.',''
        $objectFileFullName = Join-Path $objectDirPath $objectFileName
        if( -not (Test-Path -Path $objectFileFullName -PathType Leaf) )
        {
            throw ('{0}.{1} script {2} not found.' -f $Schema,$Name,$objectFileFullName)
        }
    }
    
    return $objectFileFullName
}