using System;

namespace Rivet.Operations
{
	public sealed class RemoveColumnOperation : Operation
	{
		public RemoveColumnOperation(string schemaName, string tableName, string columnName)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
