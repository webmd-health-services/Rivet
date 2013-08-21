using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Rivet.Operations
{
	public sealed class AddColumnDescriptionOperation : Operation
	{
		public AddColumnDescriptionOperation(string schemaName, string tableName, string columnName, string description)
		{
			
		}

		public override string ToQuery()
		{
			throw new NotImplementedException();
		}
	}
}
