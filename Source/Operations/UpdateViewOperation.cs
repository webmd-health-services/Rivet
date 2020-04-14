namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveViewOperation))]
	public sealed class UpdateViewOperation : ObjectOperation
	{
		public UpdateViewOperation(string schemaName, string name, string definition)
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
			return string.Format("alter view [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}