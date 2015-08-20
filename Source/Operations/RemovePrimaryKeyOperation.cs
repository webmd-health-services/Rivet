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
			return
				String.Format(
					"if exists (select * from sys.indexes where name = '{0}' and object_id = object_id('{1}.{2}', 'U')){3}\t{4}",
					Name, SchemaName, TableName, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, Name);
		}
	}
}
