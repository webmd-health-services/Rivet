


function Get-MSSqlExtendedProperty
{
    [CmdletBinding(DefaultParameterSetName='Raw')]
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session,

        [Parameter(Mandatory, ParameterSetName='ForSchema')]
        [Parameter(ParameterSetName='ForTable')]
        [Parameter(ParameterSetName='ForTableColumn')]
        [Parameter(ParameterSetName='ForView')]
        [Parameter(ParameterSetName='ForViewColumn')]
        [String] $SchemaName,

        [Parameter(Mandatory, ParameterSetName='ForTable')]
        [Parameter(Mandatory, ParameterSetName='ForTableColumn')]
        [String] $TableName,

        [Parameter(Mandatory, ParameterSetName='ForTableColumn')]
        [Parameter(Mandatory, ParameterSetName='ForViewColumn')]
        [String] $ColumnName,

        [Parameter(Mandatory, ParameterSetName='ForView')]
        [Parameter(Mandatory, ParameterSetName='ForViewColumn')]
        [String] $ViewName,

        [Object] $Name,

        [Parameter(Mandatory, ParameterSetName='RawL0')]
        [Parameter(Mandatory, ParameterSetName='RawL1')]
        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level0Type,

        [Parameter(Mandatory, ParameterSetName='RawL0')]
        [Parameter(Mandatory, ParameterSetName='RawL1')]
        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level0Name,

        [Parameter(Mandatory, ParameterSetName='RawL1')]
        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level1Type,

        [Parameter(Mandatory, ParameterSetName='RawL1')]
        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level1Name,

        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level2Type,

        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level2Name
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if ($PSCmdlet.ParameterSetName -notlike 'Raw*')
    {
        if (-not $SchemaName)
        {
            $SchemaName = 'dbo'
        }

        $l1Type = $l1Name = $l2Type = $l2Name = $null

        if ($PSCmdlet.ParameterSetName -ne 'ForSchema')
        {
            $l1Type = 'table'
            $l1Name = $TableName
            if ($PSCmdlet.ParameterSetName -like 'ForView*')
            {
                $l1Type = 'view'
                $l1Name = $ViewName
            }

            $l2Type = $null
            $l2Name = $null
            if ($PSBoundParameters.ContainsKey('ColumnName'))
            {
                $l2Type = 'column'
                $l2Name = $ColumnName
            }
        }

        return Get-MSSqlExtendedProperty -Session $Session `
                                         -Name $Name `
                                         -Level0Type 'schema' `
                                         -Level0Name $SchemaName `
                                         -Level1Type $l1Type `
                                         -Level1Name $l1Name `
                                         -Level2Type $l2Type `
                                         -Level2Name $l2Name
    }

    $parameter = @{}
    function Get-ArgValue
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, ValueFromPipeline)]
            [AllowNull()]
            [Object] $InputObject
        )

        if ($null -eq $InputObject)
        {
            return 'NULL'
        }

        if ($InputObject -eq [Rivet_QueryKeyword]::Default)
        {
            return 'default'
        }

        $paramName = "@param$($parameter.Count)"
        $parameter[$paramName] = $InputObject
        return $paramName
    }

    $nameArg = $Name | Get-ArgValue
    $l0TypeArg = $Level0Type | Get-ArgValue
    $l0NameArg = $Level0Name | Get-ArgValue
    $l1TypeArg = $Level1Type | Get-ArgValue
    $l1NameArg = $Level1Name | Get-ArgValue
    $l2TypeArg = $Level2Type | Get-ArgValue
    $l2NameArg = $Level2Name | Get-ArgValue

    $query = "select * from sys.fn_listextendedproperty(${nameArg}, ${l0TypeArg}, ${l0NameArg}, ${l1TypeArg}, ${l1NameArg}, ${l2TypeArg}, ${l2NameArg})"
    $result = Invoke-Query -Session $Session -Query $query -Parameter $parameter

    if ($result)
    {
        return $result
    }

    $msg = 'There are no extended properties on '

    if ($PSCmdlet.ParameterSetName -eq 'Raw')
    {
        $msg = "${msg}database ""$($Session.CurrentDatabase.Name)"""
    }

    function Get-LevelMessage
    {
        param(
            [Parameter(Mandatory)]
            [AllowNull()]
            [Object] $Type,

            [Parameter(Mandatory)]
            [AllowNull()]
            [Object] $Name
        )

        if ($null -eq $Type -or $Type -eq [Rivet_QueryKeyword]::Default)
        {
            return ''
        }

        if ($null -eq $Name -or $Name -eq [Rivet_QueryKeyword]::Default)
        {
            return "all ${Type}"
        }

        return "${Type} ""${Name}"""
    }

    $seperator = ''
    if ($PSCmdlet.ParameterSetName -in @('RawL0', 'RawL1', 'RawL2'))
    {
        $levelMsg = Get-LevelMessage -Type $Level0Type -Name $Level0Name
        $msg = "${msg}${levelMsg}"
        if ($levelMsg)
        {
            $seperator = ', '
        }
    }

    if ($PSCmdlet.ParameterSetName -in @('RawL1', 'RawL2'))
    {
        $levelMsg = Get-LevelMessage -Type $Level1Type -Name $Level1Name
        if ($levelMsg)
        {
            $msg = "${msg}${seperator}${levelMsg}"
            $seperator = ', '
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'RawL2')
    {
        $levelMsg = Get-LevelMessage -Type $Level2Type -Name $Level2Name
        if ($levelMsg)
        {
            $msg = "${msg}${seperator}${levelMsg}"
        }
    }

    Write-Error -Message "${msg}." -ErrorAction $ErrorActionPreference
}
