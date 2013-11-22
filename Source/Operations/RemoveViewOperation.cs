namespace Rivet.Operations
{
	public sealed class RemoveViewOperation : Operation
	{
		public RemoveViewOperation(string schemaName, string viewName)
		{
			SchemaName = schemaName;
			ViewName = viewName;
		}

		public string SchemaName { get; private set; }
		public string ViewName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("drop view [{0}].[{1}]", SchemaName, ViewName);
		}
	}
}
