using System;

namespace Rivet.Operations
{
	public sealed class RemoveForeignKeyOperation : Operation
	{
		// System Generated Constraint Name
		public RemoveForeignKeyOperation(string schemaName, string tableName, string referencesSchemaName, string referencesTableName)
		{
			Name = new ForeignKeyConstraintName(schemaName, tableName, referencesSchemaName, referencesTableName);
			SchemaName = schemaName;
			TableName = tableName;
 			ReferencesSchemaName = referencesSchemaName;
			ReferencesTableName = referencesTableName;
		}

		// Custom Constraint Name
		public RemoveForeignKeyOperation(string schemaName, string tableName, string name)
		{
			SchemaName = schemaName;
			TableName = tableName;
			Name = new ForeignKeyConstraintName(name);
		}

		public ForeignKeyConstraintName Name { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ReferencesSchemaName { get; private set; }
		public string ReferencesTableName { get; private set; }

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}', 'F') is not null{1}\t{2}", Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, Name);
		}
	}
}
