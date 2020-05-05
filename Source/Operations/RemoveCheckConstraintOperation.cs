using System;

namespace Rivet.Operations
{
	public sealed class RemoveCheckConstraintOperation : TableObjectOperation
	{
		public RemoveCheckConstraintOperation(string schemaName, string tableName, string name)
			: base(schemaName, tableName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'C') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"alter table [{SchemaName}].[{TableName}] drop constraint [{Name}]";
		}
	}
}
