using System;

namespace Rivet.Operations
{
	public sealed class AddDefaultConstraintOperation : Operation
	{
		public AddDefaultConstraintOperation(string schemaName, string tableName, string expression, string columnName,
		                                     bool withValues)
		{
			Cons = new ConstraintName(schemaName, tableName, new[]{columnName}, ConstraintType.Default);
			SchemaName = schemaName;
			TableName = tableName;
			Expression = expression;
			ColumnName = columnName;
			WithValues = withValues;
		}

		public ConstraintName Cons { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string Expression { get; private set; }
		public string ColumnName { get; private set; }
		public bool WithValues { get; private set; }


		public override string ToQuery()
		{
			var WithValuesClause = "";
			if (WithValues)
			{
				WithValuesClause = "with values";
			}

			return string.Format(@"
					alter table {0}.{1}
					add constraint {2} default {3} for {4} {5}",
					SchemaName, TableName, Cons.ReturnConstraintName(), Expression, ColumnName, WithValuesClause);
		}
	}
}
