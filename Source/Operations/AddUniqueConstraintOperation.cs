using System;

namespace Rivet.Operations
{
	public sealed class AddUniqueConstraintOperation : Operation
	{
		public AddUniqueConstraintOperation(string schemaName, string tableName, string columnName, bool clustered,
		                                    int fillFactor, string[] options, string filegroup)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
