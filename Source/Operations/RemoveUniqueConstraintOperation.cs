using System;

namespace Rivet.Operations
{
	public sealed class RemoveUniqueConstraintOperation : Operation
	{
		public RemoveUniqueConstraintOperation(string schemaName, string tableName, string[] columnName)
		{
			Cons = new ConstraintName(schemaName, tableName, columnName, ConstraintType.Unique);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone(); //Used only for testing
		}

		public ConstraintName Cons { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table {0}.{1} drop constraint {2}", SchemaName, TableName, Cons.ReturnConstraintName());
		}
	}
}
