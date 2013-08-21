using System;

namespace Rivet.Operations
{
	public sealed class AddForeignKeyOperation : Operation
	{
		public AddForeignKeyOperation(string schemaName, string tableName, string columnName, string referencesSchemaName,
		                              string referencesTableName, string referencesColumnName, string onDelete,
		                              string onUpdate, bool notForReplication)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
