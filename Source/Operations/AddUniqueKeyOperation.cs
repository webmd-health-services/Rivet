﻿using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddUniqueKeyOperation : Operation
	{
		//System Generated Constraint Name
		public AddUniqueKeyOperation(string schemaName, string tableName, string[] columnName, bool clustered,
		                                    int fillFactor, string[] options, string filegroup)
		{
			Name = new ConstraintName(schemaName, tableName, columnName, ConstraintType.UniqueKey);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
			Clustered = clustered;
			FillFactor = fillFactor;
			if (options != null) {
				Options = (string[])options.Clone();
			} else {
				Options = null;
			}
			FileGroup = filegroup;
		}

		//Custom Constraint Name
		public AddUniqueKeyOperation(string schemaName, string tableName, string[] columnName, string customConstraintName, bool clustered,
									int fillFactor, string[] options, string filegroup)
		{
			Name = new ConstraintName(customConstraintName);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
			Clustered = clustered;
			FillFactor = fillFactor;
			if (options != null)
			{
				Options = (string[])options.Clone();
			}
			else
			{
				Options = null;
			}
			FileGroup = filegroup;
		}

		public ConstraintName Name { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }
		public bool Clustered { get; private set; }
		public int FillFactor { get; private set; }
		public string[] Options { get; private set; }
		public string FileGroup { get; private set; }

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'UQ') is null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			var clusteredClause = "";
			if (Clustered)
			{
				clusteredClause = " clustered";
			}

			var fillFactorClause = "";
			var optionClause = "";		// (1)

			if (Options != null && FillFactor == 0) //Options, but no FillFactor (2)
			{
				optionClause = string.Join(", ", Options);
				optionClause = string.Format("with ({0})", optionClause);
			}

			if (Options == null && FillFactor > 0) //No Options, but with FillFactor (3)
			{
				fillFactorClause = string.Format("fillfactor = {0}", FillFactor);
				optionClause = string.Format("with ({0})", fillFactorClause);
			}

			if (Options != null && FillFactor > 0) //Options and FillFactor (4)
			{
				fillFactorClause = string.Format("fillfactor = {0}", FillFactor);
				List<string> optionsList = new List<string>(Options);
				optionsList.Add(fillFactorClause);
				Options = optionsList.ToArray();
				optionClause = string.Join(", ", Options);
				optionClause = string.Format("with ({0})", optionClause);
			}

			var fileGroupClause = "";
			if (!string.IsNullOrEmpty(FileGroup))
			{
				fileGroupClause = string.Format("on {0}", FileGroup);
			}

			var columnClause = string.Join("], [", ColumnName);

			return string.Format("alter table [{0}].[{1}] add constraint [{2}] unique{3} ([{4}]) {5} {6}", 
				SchemaName, TableName, Name, clusteredClause, columnClause, optionClause, fileGroupClause);

		}
	}
}
