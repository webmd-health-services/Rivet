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
			return String.Format("if object_id('{0}.{1}', 'C') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, Name);
		}
	}
}
