using System;

namespace Rivet.Operations
{
	public sealed class RemoveTableOperation : Operation
	{
		public RemoveTableOperation(string schemaName, string tableName)
		{
			SchemaName = schemaName;
			TableName = tableName;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("drop table [{0}].[{1}]", SchemaName, TableName);
		}
	}
}
