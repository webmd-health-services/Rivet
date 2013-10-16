using System;

namespace Rivet.Operations
{
	public sealed class RemoveColumnOperation : Operation
	{
		public RemoveColumnOperation(string schemaName, string tableName, string columnName)
		{
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = columnName;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ColumnName { get; private set; }

		public override string ToQuery()
		{
			var query = string.Format("alter table [{0}].[{1}] drop column [{2}]", SchemaName, TableName, ColumnName);
			return query;
		}
	}
}
