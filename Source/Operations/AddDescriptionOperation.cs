using System;

namespace Rivet.Operations
{
	public sealed class AddDescriptionOperation : Operation
	{
		public AddDescriptionOperation(string schemaName, string tableName, string description)
		{
			ForTable = true;
		}

		public AddDescriptionOperation(string schemaName, string tableName, string columnName, string description)
		{
			ForColumn = true;
		}

		public bool ForColumn { get; private set; }

		public bool ForTable { get; private set; }

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
