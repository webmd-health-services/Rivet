namespace Rivet.Operations
{
	public sealed class RemoveStoredProcedureOperation : Operation
	{
		public RemoveStoredProcedureOperation(string schemaName, string procedureName)
		{
			SchemaName = schemaName;
			ProcedureName = procedureName;
		}

		public string SchemaName { get; private set; }
		public string ProcedureName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("drop procedure [{0}].[{1}]", SchemaName, ProcedureName);
		}
	}
}
