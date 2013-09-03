namespace Rivet.Operations
{
	public sealed class RemoveUserDefinedFunctionOperation : Operation
	{
		public RemoveUserDefinedFunctionOperation(string schemaName, string functionName)
		{
			SchemaName = schemaName;
			FunctionName = functionName;
		}

		public string SchemaName { get; private set; }
		public string FunctionName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("drop function [{0}].[{1}]", SchemaName, FunctionName);
		}
	}
}
