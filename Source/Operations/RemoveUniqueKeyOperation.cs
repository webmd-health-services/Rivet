using System;

namespace Rivet.Operations
{
	public sealed class RemoveUniqueKeyOperation : TableObjectOperation
	{
		public RemoveUniqueKeyOperation(string schemaName, string tableName, string name, string[] columnName)
			: base(schemaName, tableName, name)
		{
			ColumnName = columnName;
		}

		public string[] ColumnName { get; }

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'UQ') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"alter table [{SchemaName}].[{TableName}] drop constraint [{Name}]";
		}
	}
}
