﻿using System;
using System.Collections.Generic;
using System.Linq;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemovePrimaryKeyOperation))]
	public sealed class AddPrimaryKeyOperation : ConstraintOperation
	{
		public AddPrimaryKeyOperation(string schemaName, string tableName, string name, string[] columnName,
			bool nonClustered, string[] options)
			: base(schemaName, tableName, name, ConstraintType.PrimaryKey)
		{
			ColumnName = new List<string>(columnName);
			NonClustered = nonClustered;
			Options = options != null ? options.ToList() : new List<string>();
		}

		public List<string> ColumnName { get; }

		public bool NonClustered { get; set; }

		public List<string> Options { get; }

		public override string ToIdempotentQuery()
		{
			return $"if not exists (select * from sys.indexes where name = '{Name}' and object_id = object_id('{SchemaName}.{TableName}', 'U')){Environment.NewLine}" +
			       $"    {ToQuery()}";
		}

		public override string ToQuery()
		{
			var clusteredClause = "clustered";
			if (NonClustered)
			{
				// ReSharper disable once StringLiteralTypo
				clusteredClause = "nonclustered";
			}

			var optionClause = "";
			if (!(Options == null || Options.Count == 0))
			{
				optionClause = string.Join(", ", Options.ToArray());
				optionClause = $" with ( {optionClause} )";
			}

			var columnClause = string.Join("], [", ColumnName.ToArray());

			return
				$"alter table [{SchemaName}].[{TableName}] add constraint [{Name}] primary key {clusteredClause} ([{columnClause}]){optionClause}";
		}
	}
}
