namespace Rivet.Operations
{
	public sealed class UpdateTriggerOperation : ObjectOperation
	{
		public UpdateTriggerOperation(string schemaName, string name, string definition)
			: base(schemaName, name)
		{
			Definition = definition;
		}

		public string Definition { get; set; }

		public override string ToIdempotentQuery()
		{
			return ToQuery();
		}

		public override string ToQuery()
		{
			return string.Format("alter trigger [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}