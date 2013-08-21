using System;

namespace Rivet.Operations
{
	public sealed class AddPrimaryKeyOperation : Operation
	{
		public AddPrimaryKeyOperation(string schemaName, string tableName, string columnName, bool nonClustered,
		                              string[] options)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
