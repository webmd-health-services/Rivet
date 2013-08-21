using System;

namespace Rivet.Operations
{
	public sealed class RemoveDescriptionOperation  : Operation
	{
		public RemoveDescriptionOperation(string schemaName, string tableName, string columnName)
		{
			ForFolumn = true;
		}

		public RemoveDescriptionOperation(string schemaName, string tableName)
		{
			ForTable = true;
		}

		public bool ForFolumn { get; private set; }
		public bool ForTable { get; private set; }
		
		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
