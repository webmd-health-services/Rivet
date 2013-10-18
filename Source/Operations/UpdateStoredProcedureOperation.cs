namespace Rivet.Operations
{
	public sealed class UpdateStoredProcedureOperation : Operation
	{
		public UpdateStoredProcedureOperation(string schemaName, string name, string definition)
		{
			SchemaName = schemaName;
			Name = name;
			Definition = definition;
		}


		public string SchemaName { get; private set; }
		public string Name { get; private set; }
		public string Definition { get; private set; }


		public override string ToQuery()
		{
			return string.Format(@"alter procedure [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}