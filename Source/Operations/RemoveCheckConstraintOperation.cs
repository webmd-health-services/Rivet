using System;

namespace Rivet.Operations
{
	public sealed class RemoveCheckConstraintOperation : Operation
	{
		public RemoveCheckConstraintOperation(string schemaName, string tableName, string name)
		{

			SchemaName = schemaName;
			TableName = tableName;
			Name = name;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string Name { get; private set; }

		public override string ToIdempotentQuery()
		{
			return String.Format("if object_id('{0}', 'C') is not null{1}\t{2}", Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, Name);
		}
	}
}
