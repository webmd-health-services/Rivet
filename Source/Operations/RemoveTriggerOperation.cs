namespace Rivet.Operations
{
	public sealed class RemoveTriggerOperation : Operation
	{
		public RemoveTriggerOperation(string schemaName, string triggerName)
		{
			SchemaName = schemaName;
			TriggerName = triggerName;
		}

		public string SchemaName { get; private set; }
		public string TriggerName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("drop trigger [{0}].[{1}]", SchemaName, TriggerName);
		}
	}
}
