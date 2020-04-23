using System;

namespace Rivet.Operations
{
	public sealed class RemoveForeignKeyOperation : TableObjectOperation
	{
		// Custom Constraint Name
		public RemoveForeignKeyOperation(string schemaName, string tableName, string name)
			: base(schemaName, tableName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'F') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"alter table [{SchemaName}].[{TableName}] drop constraint [{Name}]";
		}
	}
}
