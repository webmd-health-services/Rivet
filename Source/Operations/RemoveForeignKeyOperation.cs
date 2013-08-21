using System;

namespace Rivet.Operations
{
	public sealed class RemoveForeignKeyOperation : Operation
	{
		public RemoveForeignKeyOperation(string schemaName, string tableName, string referencesSchemaName, string referencesTableName)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
