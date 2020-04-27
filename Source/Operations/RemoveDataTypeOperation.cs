using System;

namespace Rivet.Operations
{
	public sealed class RemoveDataTypeOperation : ObjectOperation
	{
		public RemoveDataTypeOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'TT') is not null or type_id('{SchemaName}.{Name}') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"drop type [{SchemaName}].[{Name}]";
		}
	}
}