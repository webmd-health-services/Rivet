
function Add-Table
{
    <#
    .SYNOPSIS
    Creates a new table in the database.

    .DESCRIPTION
    The column's for the table should be created and returned in a script block, which is passed as the value of the `Column` parameter.  For example,

        Add-Table 'Suits' {
            New-Column 'id' -Int -Identity
            New-Column 'pieces -TinyInt -NotNull
            New-Column 'color' -VarChar -NotNull
        }

    Add-Table supports plugins.  At the end of the Add-Table migration, Invoke-MigrationEvent is invoked which will look for a script "Complete-AddTable.ps1" in the Plugins directory as defined by rivet.json.  For more information, see about_Rivet_Plugins
    
    .EXAMPLE
    Add-Table -Name 'Ties' -Column { New-Column 'color' -VarChar -NotNull }

    Creates a `Ties` table with a single column for each tie's color.  Pretty!
    #>
    [CmdletBinding(DefaultParameterSetName='AsNormalTable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table.
        $Name,

        [string]
        # The table's schema.  Defaults to 'dbo'.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='AsNormalTable')]
        [ScriptBlock]
        # A script block that returns the table's columns using the `New-Column` function.
        $Column,

        [Parameter(Mandatory=$true,ParameterSetName='AsFileTable')]
        [Switch]
        # Creates a [FileTable](http://msdn.microsoft.com/en-us/library/ff929144.aspx) table.
        $FileTable,

        [string]
        # Specifies the partition scheme or filegroup on which the table is stored, e.g. `ON $FileGroup`
        $FileGroup,

        [string]
        # The filegroup where text, ntext, image, xml, varchar(max), nvarchar(max), and varbinary(max) columns are stored. The table has to have one of those columns. For example, `TEXTIMAGE_ON $TextImageFileGroup`.
        $TextImageFileGroup,

        [string]
        # Specifies the filegroup for FILESTREAM data, e.g. `FILESTREAM_ON $FileStreamFileGroup`.
        $FileStreamFileGroup,

        [string[]]
        # Specifies one or more table options.
        $Option,

        [string]
        # A description of the table.
        $Description

    )
    
    $columnDefinitionClause = ''
    if( $PSCmdlet.ParameterSetName -eq 'AsNormalTable' )
    {
        $columns = & $Column
        $columnDefinitions = $columns | 
                                ForEach-Object { $_.GetColumnDefinition( $SchemaName, $Name ) }
        $columnDefinitionClause = @'
(
        {0}
    )
'@ -f ($columnDefinitions -join ",`n        ")
    }
    else
    {
        $columnDefinitionClause = 'as FileTable'
    }

    $fileGroupClause = ''
    if( $FileGroup )
    {
        $fileGroupClause = 'on {0}' -f $FileGroup
    }

    $textImageFileGroupClause = ''
    if( $TextImageFileGroup )
    {
        $textImageFileGroupClause = 'textimage_on {0}' -f $TextImageFileGroup
    }

    $fileStreamFileGroupClause = ''
    if( $FileStreamFileGroup )
    {
        $fileStreamFileGroupClause = 'filestream_on {0}' -f $FileStreamFileGroup
    }

    $optionClause = ''
    if( $Option )
    {
       $optionClause = 'with ( {0} )' -f ($Option -join ', ')
    }

    Write-Host (' +{0}.{1}' -f $SchemaName,$Name)
    $query = @'
    create table [{0}].[{1}] {2}
        {3}
        {4}
        {5}
        {6}
'@ -f $SchemaName,$Name,$columnDefinitionClause,$fileGroupClause,$textImageFileGroupClause,$fileStreamFileGroupClause,$optionClause

    Invoke-Query -Query $query

    $addDescriptionArgs = @{
                                SchemaName = $SchemaName;
                                TableName = $Name;
                            }

    if( $Description )
    {
        Add-Description -Description $Description @addDescriptionArgs -ForTable -Quiet
    }

    $columns | 
        Where-Object { $_.Description } |
        ForEach-Object { Add-Description -Description $_.Description -ColumnName $_.Name @addDescriptionArgs -Quiet }

    ## Migration Event Call

    Invoke-MigrationEvent -OnComplete -Name 'AddTable' -EventArg @{ TableName = $Name ; SchemaName = $SchemaName }

}


