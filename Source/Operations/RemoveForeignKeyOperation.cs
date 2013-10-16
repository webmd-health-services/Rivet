namespace Rivet.Operations
{
	public sealed class RemoveForeignKeyOperation : Operation
	{
		public RemoveForeignKeyOperation(string schemaName, string tableName, string referencesSchemaName, string referencesTableName)
		{
			ForeignKeyConstraintName = new ForeignKeyConstraintName(schemaName, tableName, referencesSchemaName, referencesTableName);
			SchemaName = schemaName;
			TableName = tableName;
 			ReferencesSchemaName = referencesSchemaName; //Testing Purposes Only
			ReferencesTableName = referencesTableName; //Testing Purposes Only
		}

		public ForeignKeyConstraintName ForeignKeyConstraintName { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ReferencesSchemaName { get; private set; }
		public string ReferencesTableName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, ForeignKeyConstraintName);
		}
	}
}
