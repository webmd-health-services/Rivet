using System;

namespace Rivet.Operations
{
	public sealed class AddIndexOperation : Operation
	{
		public AddIndexOperation(string schemaName, string tableName, string columnName, bool unique, bool clustered,
		                         string[] options, string where, string fileGroup)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
