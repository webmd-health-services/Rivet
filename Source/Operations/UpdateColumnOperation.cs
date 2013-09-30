using System;

namespace Rivet.Operations
{
	public sealed class UpdateColumnOperation : Operation
	{
		public UpdateColumnOperation(string schemaName, string tableName, Column column)
		{
			TableName = tableName;
			SchemaName = schemaName;
			Column = column;
		}
		
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public Column Column { get; private set; }

		public override string ToQuery()
		{
			var columnDefinition = Column.GetColumnDefinition(TableName, SchemaName, false);
			return string.Format("alter table [{0}].[{1}] alter column {2}", SchemaName, TableName, columnDefinition);
		}
	}
}
