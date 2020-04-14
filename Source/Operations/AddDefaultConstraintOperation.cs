using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveDefaultConstraintOperation))]
	public sealed class AddDefaultConstraintOperation : ConstraintOperation
	{
		public AddDefaultConstraintOperation(string schemaName, string tableName, string expression, string columnName,
											 bool withValues)
			: base(schemaName, tableName, new ConstraintName(schemaName, tableName, new[]{columnName}, ConstraintType.Default).ToString(), ConstraintType.Default)
		{
			Expression = expression;
			ColumnName = columnName;
			WithValues = withValues;
		}

		public AddDefaultConstraintOperation(string schemaName, string tableName, string expression, string columnName, string name,
									 bool withValues)
			: this(schemaName, tableName, expression, columnName, withValues)
		{
			Name = name;
		}

		public string ColumnName { get; set; }

		public string Expression { get; set; }

		public bool WithValues { get; set; }

		public override string ToIdempotentQuery()
		{
			return String.Format("if object_id('{0}.{1}', 'D') is null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			var withValuesClause = "";
			if (WithValues)
			{
				withValuesClause = "with values";
			}

			return string.Format("alter table [{0}].[{1}] add constraint [{2}] default {3} for [{4}] {5}",
					SchemaName, TableName, Name, Expression, ColumnName, withValuesClause);
		}
	}
}
