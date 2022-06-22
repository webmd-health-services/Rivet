using System;

namespace Rivet.Operations
{
	public sealed class RemoveSynonymOperation : ObjectOperation
	{
		public RemoveSynonymOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'SN') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"drop synonym [{SchemaName}].[{Name}]";
		}
	}
}