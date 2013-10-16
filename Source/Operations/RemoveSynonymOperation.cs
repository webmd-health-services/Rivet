namespace Rivet.Operations
{
	public sealed class RemoveSynonymOperation : Operation
	{
		public RemoveSynonymOperation(string schemaName, string name)
		{
			SchemaName = schemaName;
			Name = name;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }

		public override string ToQuery()
		{
			return string.Format(@"drop synonym {0}.{1}", SchemaName, Name);
		}
	}
}