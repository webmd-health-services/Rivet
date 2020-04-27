using System;

namespace Rivet.Operations
{
	public sealed class RemoveViewOperation : ObjectOperation
	{
		public RemoveViewOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'V') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"drop view [{SchemaName}].[{Name}]";
		}
	}
}
