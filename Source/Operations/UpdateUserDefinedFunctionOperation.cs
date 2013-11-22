namespace Rivet.Operations
{
	public sealed class UpdateUserDefinedFunctionOperation : Operation
	{
		public UpdateUserDefinedFunctionOperation(string schemaName, string name, string definition)
		{
			SchemaName = schemaName;
			Name = name;
			Definition = definition;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }
		public string Definition { get; private set; }

		public override string ToIdempotentQuery()
		{
			return ToQuery();
		}

		public override string ToQuery()
		{
			return string.Format("alter function [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}