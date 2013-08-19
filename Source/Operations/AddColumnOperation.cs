namespace Rivet.Operations
{
	public sealed class AddColumnOperation : Operation
	{
		public AddColumnOperation(string tableName, string schemaName)
		{
			TableName = tableName;
			SchemaName = schemaName;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] add {2}", SchemaName, TableName, "definition");
		}
	}
}
