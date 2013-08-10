using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddTableOperation : Operation
	{
		public AddTableOperation(string tableName, string schemaName)
		{
			TableName = tableName;
			SchemaName = schemaName;
			Columns = new List<object>();
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public List<object> Columns { get; private set; }

		public override string ToQuery()
		{
			return "";
		}
	}
}
