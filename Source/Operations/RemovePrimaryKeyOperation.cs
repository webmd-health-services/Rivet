using System;

namespace Rivet.Operations
{
	public sealed class RemovePrimaryKeyOperation : TableObjectOperation
	{
		public RemovePrimaryKeyOperation(string schemaName, string tableName, string name)
			: base(schemaName, tableName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return $"if exists (select * from sys.indexes where name = '{Name}' and object_id = object_id('{SchemaName}.{TableName}', 'U')){Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"alter table [{SchemaName}].[{TableName}] drop constraint [{Name}]";
		}
	}
}
