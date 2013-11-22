using System;

namespace Rivet.Operations
{
	public sealed class RemoveDataTypeOperation : Operation
	{
		public RemoveDataTypeOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }

		public override string ToIdempotentQuery()
		{
			return String.Format("if object_id('{0}.{1}', 'TT') is not null or type_id('{0}.{1}') is not null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			return string.Format("drop type [{0}].{1}", SchemaName, Name);
		}
	}
}