using System;

namespace Rivet.Operations
{
	public sealed class RemoveTableOperation : ObjectOperation
	{
		public RemoveTableOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'U') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"drop table [{SchemaName}].[{Name}]";
		}
	}
}
