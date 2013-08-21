namespace Rivet.Operations
{
	public sealed class AddSchemaOperation : Operation
	{
		public AddSchemaOperation(string schemaName, string schemaOwner)
		{
			SchemaName = schemaName;
			SchemaOwner = schemaOwner;
		}

		public string SchemaName { get; private set; }
		public string SchemaOwner { get; private set; }
		
		public override string ToQuery()
		{
			string query = string.Format("create schema [{0}]", SchemaName);
			
			if (!string.IsNullOrEmpty(SchemaOwner)) 
			{
				query = string.Format("{0} authorization [{1}]", query, SchemaOwner);
			}

			return query;
		}
	}
}
