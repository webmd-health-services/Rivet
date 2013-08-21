using System;

namespace Rivet.Operations
{
	public sealed class RemoveTableOperation : Operation
	{
		public RemoveTableOperation(string schemaName, string tableName)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
