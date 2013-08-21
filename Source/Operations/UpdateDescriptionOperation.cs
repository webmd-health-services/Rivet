using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Rivet.Operations
{
	public sealed class UpdateDescriptionOperation : Operation
	{

		public UpdateDescriptionOperation(string schemaName, string tableName, string description)
		{
			ForTable = true;
		}

		public UpdateDescriptionOperation(string schemaName, string tableName, string columnName, string description)
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
