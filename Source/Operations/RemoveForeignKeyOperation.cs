using System;

namespace Rivet.Operations
{
	public sealed class RemoveForeignKeyOperation : Operation
	{
		public RemoveForeignKeyOperation(string schemaName, string tableName, string referencesSchemaName, string referencesTableName)
		{
			Cons = new ForeignConstraintName(schemaName, tableName, referencesSchemaName, referencesTableName);
			SchemaName = schemaName; //Testing Purposes Only
			TableName = tableName;
 			ReferencesSchemaName = referencesSchemaName; //Testing Purposes Only
			ReferencesTableName = referencesTableName; //Testing Purposes Only
		}

		public ForeignConstraintName Cons { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ReferencesSchemaName { get; private set; }
		public string ReferencesTableName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table {0} drop constraint {1}", TableName, Cons.ReturnConstraintName());
		}
	}
}
