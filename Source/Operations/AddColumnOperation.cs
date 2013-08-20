namespace Rivet.Operations
{
	public sealed class AddColumnOperation : Operation
	{
		public AddColumnOperation(string tableName, string schemaName, Column column, bool withValues)
		{
			Column = column;
			TableName = tableName;
			SchemaName = schemaName;
			WithValues = withValues;
		}

		public Column Column { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public bool WithValues { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] add {2}", SchemaName, TableName, Column.GetColumnDefinition(TableName, SchemaName, WithValues));
		}
	}
}
