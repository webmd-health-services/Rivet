namespace Rivet.Operations
{
	public sealed class RemoveViewOperation : Operation
	{
		public RemoveViewOperation(string schemaName, string procedureName)
		{
			SchemaName = schemaName;
			ProcedureName = procedureName;
		}

		public string SchemaName { get; private set; }
		public string ProcedureName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("drop view [{0}].[{1}]", SchemaName, ProcedureName);
		}
	}
}
