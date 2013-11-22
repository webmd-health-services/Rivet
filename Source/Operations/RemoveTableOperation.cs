using System;

namespace Rivet.Operations
{
	public sealed class RemoveTableOperation : Operation
	{
		public RemoveTableOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'U') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop table [{0}].[{1}]", SchemaName, Name);
		}
	}
}
