namespace Rivet.Operations
{
	public sealed class RemoveUniqueKeyOperation : Operation
	{
		//System Generated Constraint Name
		public RemoveUniqueKeyOperation(string schemaName, string tableName, string[] columnName)
		{
			ConstraintName = new ConstraintName(schemaName, tableName, columnName, ConstraintType.Unique);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone(); //Used only for testing
		}

		//Custom Constraint Name
		public RemoveUniqueKeyOperation(string schemaName, string tableName, string[] columnName, string customConstraintName)
		{
			ConstraintName = new ConstraintName(customConstraintName);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone(); //Used only for testing
		}

		public ConstraintName ConstraintName { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, ConstraintName.ToString());
		}
	}
}
