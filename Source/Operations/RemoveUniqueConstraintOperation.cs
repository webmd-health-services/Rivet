using System;

namespace Rivet.Operations
{
	public sealed class RemoveUniqueConstraintOperation : Operation
	{
		public RemoveUniqueConstraintOperation(string schemaName, string tableName, string columnName)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
