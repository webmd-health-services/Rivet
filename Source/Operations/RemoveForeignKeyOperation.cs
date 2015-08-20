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
			return string.Format("if object_id('{0}.{1}', 'F') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, Name);
		}
	}
}
