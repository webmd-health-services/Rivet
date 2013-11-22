using System;

namespace Rivet.Operations
{
	public sealed class RemoveViewOperation : Operation
	{
		public RemoveViewOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'V') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop view [{0}].[{1}]", SchemaName, Name);
		}
	}
}
