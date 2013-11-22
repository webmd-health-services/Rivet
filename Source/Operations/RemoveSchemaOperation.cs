namespace Rivet.Operations
{
	public sealed class RemoveSchemaOperation : Operation
	{
		public RemoveSchemaOperation(string schemaName)
		{
			SchemaName = schemaName;
		}

		public string SchemaName { get; private set; }

		public override string ToQuery()
		{
			string query = string.Format("drop schema [{0}]", SchemaName);
			return query;
		}
	}
}
