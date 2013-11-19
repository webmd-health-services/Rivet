namespace Rivet.Operations
{
	public sealed class RemoveIndexOperation : Operation
	{
		public RemoveIndexOperation(string schemaName, string tableName, string [] columnName)
		{
			Name = new ConstraintName(schemaName, tableName, columnName, ConstraintType.Index);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
		}

		public RemoveIndexOperation(string schemaName, string tableName, string name)
		{
			Name = new ConstraintName(name);
			SchemaName = schemaName;
			TableName = tableName;
		}

		public ConstraintName Name { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string [] ColumnName { get; private set; }

		public override string ToQuery()
		{

			return string.Format("drop index [{0}] on [{1}].[{2}]", Name, SchemaName, TableName);

		}
	}
}
