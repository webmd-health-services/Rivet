using System;

namespace Rivet.Operations
{
	public sealed class RemoveDefaultConstraintOperation : Operation
	{
		public RemoveDefaultConstraintOperation(string schemaName, string tableName, string columnName)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
