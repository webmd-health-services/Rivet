using System;

namespace Rivet.Operations
{
	public sealed class AddDefaultConstraintOperation : Operation
	{
		//System Generated Constraint Name
		public AddDefaultConstraintOperation(string schemaName, string tableName, string expression, string columnName,
		                                     bool withValues)
		{
			Name = new ConstraintName(schemaName, tableName, new[]{columnName}, ConstraintType.Default);
			SchemaName = schemaName;
			TableName = tableName;
			Expression = expression;
			ColumnName = columnName;
			WithValues = withValues;
		}

		//Custom Constraint Name
		public AddDefaultConstraintOperation(string schemaName, string tableName, string expression, string columnName, string name,
									 bool withValues)
		{
			Name = new ConstraintName(name);
			SchemaName = schemaName;
			TableName = tableName;
			Expression = expression;
			ColumnName = columnName;
			WithValues = withValues;
		}

		public ConstraintName Name { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string Expression { get; private set; }
		public string ColumnName { get; private set; }
		public bool WithValues { get; private set; }

		public override string ToIdempotentQuery()
		{
			return String.Format("if object_id('{0}', 'D') is null{1}\t{2}", Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			var withValuesClause = "";
			if (WithValues)
			{
				withValuesClause = "with values";
			}

			return string.Format("alter table [{0}].[{1}] add constraint [{2}] default {3} for {4} {5}",
					SchemaName, TableName, Name, Expression, ColumnName, withValuesClause);
		}
	}
}
