using System;

namespace Rivet.Operations
{
	public sealed class RemoveTriggerOperation : Operation
	{
		public RemoveTriggerOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }

		public override string ToIdempotentQuery()
		{
			return String.Format("if object_id('{0}.{1}', 'TR') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop trigger [{0}].[{1}]", SchemaName, Name);
		}
	}
}
