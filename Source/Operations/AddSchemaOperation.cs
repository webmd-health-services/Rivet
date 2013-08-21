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
            string query;
            if (SchemaOwner == "" || SchemaOwner == null)
            {
                query = string.Format("create schema [{0}]", SchemaName);
            }
			else
			{
                query = string.Format("create schema [{0}] authorization [{1}]", SchemaName, SchemaOwner);
			}
			return query;
		}
	}
}