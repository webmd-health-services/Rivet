using System;

namespace Rivet.Operations
{
	public sealed class RemoveTriggerOperation : ObjectOperation
	{
		public RemoveTriggerOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'TR') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"drop trigger [{SchemaName}].[{Name}]";
		}
	}
}
