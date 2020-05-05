namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveStoredProcedureOperation))]
	public sealed class UpdateStoredProcedureOperation : ObjectOperation
	{
		public UpdateStoredProcedureOperation(string schemaName, string name, string definition)
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
			return string.Format("alter procedure [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}