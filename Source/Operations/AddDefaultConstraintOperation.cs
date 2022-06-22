using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveDefaultConstraintOperation))]
	public sealed class AddDefaultConstraintOperation : ConstraintOperation
	{
		public AddDefaultConstraintOperation(string schemaName, string tableName, string name, string columnName,
			string expression, bool withValues)
			: base(schemaName, tableName, name, ConstraintType.Default)
		{
			Expression = expression;
			ColumnName = columnName;
			WithValues = withValues;
		}

		public string ColumnName { get; set; }

		public string Expression { get; set; }

		public bool WithValues { get; set; }

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'D') is null{Environment.NewLine}" +
				   $"    {ToQuery()}";
		}

		public override string ToQuery()
		{
			var withValuesClause = "";
			if (WithValues)
			{
				withValuesClause = " with values";
			}

			return $"alter table [{SchemaName}].[{TableName}] add constraint [{Name}] default {Expression} for [{ColumnName}]{withValuesClause}";
		}
	}
}
