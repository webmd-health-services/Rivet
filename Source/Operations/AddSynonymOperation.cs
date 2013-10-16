namespace Rivet.Operations
{
	public sealed class AddSynonymOperation : Operation
	{
		public AddSynonymOperation(string schemaName, string name, string targetSchemaName, string targetDatabaseName, string targetObjectName)
		{
			SchemaName = schemaName;
			Name = name;
			TargetSchemaName = targetSchemaName;
			TargetDatabaseName = targetDatabaseName;
			TargetObjectName = targetObjectName;
		}

		public string SchemaName { get; private set; }
		public string Name { get; private set; }
		public string TargetSchemaName { get; private set; }
		public string TargetDatabaseName { get; private set; }
		public string TargetObjectName { get; private set; }

		public override string ToQuery()
		{
			if (string.IsNullOrEmpty(TargetDatabaseName))
			{
				return string.Format(@"create synonym {0}.{1} for {2}.{3}", SchemaName, Name, TargetSchemaName, TargetObjectName);
			}
			return string.Format(@"create synonym {0}.{1} for {2}.{3}.{4}", SchemaName, Name, TargetDatabaseName, TargetSchemaName, TargetObjectName);
		}
	}
}