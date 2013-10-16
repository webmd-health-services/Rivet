namespace Rivet.Operations
{
	public sealed class AddTriggerOperation : Operation
	{
		public AddTriggerOperation(string schemaName, string name, string definition)
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
			return string.Format(@"create trigger [{0}].[{1}] {2}", SchemaName, Name, Definition);
		}
	}
}