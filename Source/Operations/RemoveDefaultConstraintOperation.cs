using System;

namespace Rivet.Operations
{
	public sealed class RemoveDefaultConstraintOperation : TableObjectOperation
	{
		public RemoveDefaultConstraintOperation(string schemaName, string tableName, string columnName, string name)  
			: base(schemaName, tableName, name)
		{
			ColumnName = columnName;
		}

		public string ColumnName { get; set; }

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'D') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"alter table [{SchemaName}].[{TableName}] drop constraint [{Name}]";
		}
	}
}
