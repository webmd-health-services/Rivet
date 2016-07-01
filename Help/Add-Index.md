---
external help file: Rivet.dll-Help.xml
online version: 
schema: 2.0.0
---

# Add-Index

## SYNOPSIS
Creates a relational index on a specified table.


## SYNTAX

```
Add-Index [-SchemaName <String>] [-TableName] <String> [-ColumnName <String[]>] [-Name <String>] 
[-Include <String[]>] [-Descending <Boolean[]>] [-Unique] [-Clustered] [-Option <String[]>] 
[-Where <String>] [-On <String>] [-FileStreamOn <String>] [-Timeout <Int32>]
```

## DESCRIPTION
Creates a relational index on a specified table.  An index can be created before there is data on the table.  Relational indexes can be created on tables or views in another database by specifying a qualified database name.


## EXAMPLES

### Example 1
```
Add-Index -TableName Cars -Column Year
```

Adds a relational index in 'Year' on the table 'Cars'


### Example 2
```
Add-Index -TableName 'Cars' -Column 'Year' -Unique -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF')
```

Adds an unique relational index in 'Year' on the table 'Cars' with options to ignore duplicate keys and disallow row locks.

### Example 3
```
Add-Index -TableName 'Cars' -Column 'Year' -Include 'Model'
```

Adds a relational index in 'Year' on the table 'Cars' and includes the column 'Model'



## PARAMETERS

### -Clustered
Creates a clustered index, otherwise non-clustered

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -ColumnName
The column(s) on which the index is based.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Descending
Optional array of booleans to specify descending switch per column.  Length must match `ColumnName`.

```yaml
Type: Boolean[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileStreamOn
The value of the `FILESTREAM_ON` clause, which controls the placement of filestream data.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include
Column names to include in the index.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The name for the <object type>. If not given, a sensible name will be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -On
The value of the `ON` clause, which controls the filegroup/partition to use for the index.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Option
An array of index options.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -SchemaName
The schema name of the target table.  Defaults to `dbo`.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -TableName
The name of the target table.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Timeout
The number of seconds to wait for the add operation to complete. Default is 30 seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unique
Create a unique index on a table or view.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

### -Where
The filter to use when creating a filtered index.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None


## OUTPUTS

### Rivet.Operations.AddIndexOperation

## NOTES

## RELATED LINKS

