namespace Rivet.Operations
{
	public sealed class RemovePrimaryKeyOperation : Operation
	{
		public RemovePrimaryKeyOperation(string schemaName, string tableName, string[] columnName)
		{
			Name = new ConstraintName(schemaName, tableName, columnName, ConstraintType.PrimaryKey);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
		}

		public RemovePrimaryKeyOperation(string schemaName, string tableName, string name)
		{
			Name = new ConstraintName(name);
			SchemaName = schemaName;
			TableName = tableName;
		}

		public ConstraintName Name { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, Name);
		}
	}
}
