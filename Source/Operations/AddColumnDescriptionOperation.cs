using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Rivet.Operations
{
	public sealed class AddColumnDescriptionOperation : Operation
	{
		public AddColumnDescriptionOperation(string tableName, string schemaName, string columnName, string description)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
