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
			return $"if object_id('{SchemaName}.{Name}', 'UQ') is null{Environment.NewLine}    {ToQuery()}";
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
				allOptions.Add($"fillfactor = {FillFactor}");
			}

			var optionClause = "";
			if (allOptions.Count > 0)
			{
				optionClause = $" with ({string.Join(", ", allOptions.ToArray())})";
			}

			var fileGroupClause = "";
			if (!string.IsNullOrEmpty(FileGroup))
			{
				fileGroupClause = $" on {FileGroup}";
			}

			var columnClause = string.Join("], [", ColumnName.ToArray());

			return $"alter table [{SchemaName}].[{TableName}] add constraint [{Name}] unique{clusteredClause} ([{columnClause}]){optionClause}{fileGroupClause}";

		}
	}
}
