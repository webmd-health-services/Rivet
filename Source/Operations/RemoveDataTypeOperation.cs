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

		public override string ToQuery()
		{
			return string.Format("drop type [{0}].{1}", SchemaName, Name);
		}
	}
}