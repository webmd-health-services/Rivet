using System;

namespace Rivet.Operations
{
	public sealed class AddDefaultConstraintOperation : Operation
	{
		public AddDefaultConstraintOperation(string schemaName, string tableName, string expression, string columnName,
		                                     bool withValues)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
