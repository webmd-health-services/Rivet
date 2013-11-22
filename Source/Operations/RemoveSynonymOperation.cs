using System;

namespace Rivet.Operations
{
	public sealed class RemoveSynonymOperation : Operation
	{
		public RemoveSynonymOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }

		public override string ToIdempotentQuery()
		{
			return string.Format("if object_id('{0}.{1}', 'SN') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop synonym [{0}].[{1}]", SchemaName, Name);
		}
	}
}