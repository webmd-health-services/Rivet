using System;

namespace Rivet.Operations
{
	public sealed class RemoveDefaultConstraintOperation : Operation
	{
		public RemoveDefaultConstraintOperation(string schemaName, string tableName, string columnName)
		{
			Cons = new ConstraintName(schemaName, tableName, new[] { columnName }, ConstraintType.Default);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = columnName; //For Testing Purposes Only
		}

		public ConstraintName Cons { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ColumnName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table {0}.{1} drop constraint {2}", SchemaName, TableName, Cons.ReturnConstraintName());
		}
	}
}
