using System;

namespace Rivet.Operations
{
	public sealed class RemovePrimaryKeyOperation : Operation
	{
		public RemovePrimaryKeyOperation(string schemaName, string tableName, string columnName)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
