using System;

namespace Rivet.Operations
{
	public sealed class RemoveIndexOperation : Operation
	{
		public RemoveIndexOperation(string schemaName, string tableName, string columnName)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
