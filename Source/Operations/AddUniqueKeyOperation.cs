using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveUniqueKeyOperation))]
	public sealed class AddUniqueKeyOperation : ConstraintOperation
	{
		public AddUniqueKeyOperation(string schemaName, string tableName, string name, string[] columnName,
			bool clustered, int fillFactor, string[] options, string fileGroup)
			: base(schemaName, tableName, name, ConstraintType.UniqueKey)
		{
			ColumnName = new List<string>(columnName);
			Clustered = clustered;
			FillFactor = fillFactor;
			Options = new List<string>(options ?? new string[0]);
			FileGroup = fileGroup;
		}

		public bool Clustered { get; set; }

		public List<string> ColumnName { get; }

		public string FileGroup { get; set; }

		public int FillFactor { get; set; }

		public List<string> Options { get; }

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

			var allOptions = new List<string>(Options);
			if (FillFactor > 0)
			{
				allOptions.Add(string.Format("fillfactor = {0}", FillFactor));
			}

			var optionClause = "";
			if (allOptions.Count > 0)
			{
				optionClause = string.Format(" with ({0})", string.Join(", ", allOptions.ToArray()));
			}

			var fileGroupClause = "";
			if (!string.IsNullOrEmpty(FileGroup))
			{
				fileGroupClause = string.Format(" on {0}", FileGroup);
			}

			var columnClause = string.Join("], [", ColumnName.ToArray());

			return string.Format("alter table [{0}].[{1}] add constraint [{2}] unique{3} ([{4}]){5}{6}", 
				SchemaName, TableName, Name, clusteredClause, columnClause, optionClause, fileGroupClause);

		}
	}
}
