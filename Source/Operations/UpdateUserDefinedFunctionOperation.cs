namespace Rivet.Operations
{
	public sealed class UpdateUserDefinedFunctionOperation : ObjectOperation
	{
		public UpdateUserDefinedFunctionOperation(string schemaName, string name, string definition)
			: base(schemaName, name)
		{
			Definition = definition;
		}

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