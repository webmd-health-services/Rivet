using System;

namespace Rivet.Operations
{
	public sealed class AddDefaultConstraintOperation : TableObjectOperation
	{
		public AddDefaultConstraintOperation(string schemaName, string tableName, string expression, string columnName,
		                                     bool withValues)
			: base(schemaName, tableName, new ConstraintName(schemaName, tableName, new[]{columnName}, ConstraintType.Default).ToString())
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

		public string ColumnName { get; private set; }
		public string Expression { get; private set; }
		public bool WithValues { get; private set; }

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
