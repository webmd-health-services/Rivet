using System;

namespace Rivet.Operations
{
	public sealed class RemovePrimaryKeyOperation : Operation
	{
		public RemovePrimaryKeyOperation(string schemaName, string tableName, string[] columnName)
		{
			Cons = new ConstraintName(schemaName, tableName, columnName, ConstraintType.PrimaryKey);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
		}

		public ConstraintName Cons { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table {0} drop constraint {1}", TableName, Cons.ReturnConstraintName());
		}
	}
}
