namespace Rivet.Operations
{
	public sealed class RemoveIndexOperation : Operation
	{
		public RemoveIndexOperation(string schemaName, string tableName, string [] columnName)
		{
			ConstraintName = new ConstraintName(schemaName, tableName, columnName, ConstraintType.Index);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
		}

		public ConstraintName ConstraintName { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string [] ColumnName { get; private set; } //Only for testing purposes

		public override string ToQuery()
		{
			return string.Format("drop index [{0}] on [{1}].[{2}]", ConstraintName.ToString(), SchemaName, TableName);
		}
	}
}
