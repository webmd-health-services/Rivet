using System;

namespace Rivet.Operations
{
	public sealed class RemoveStoredProcedureOperation : ObjectOperation
	{
		public RemoveStoredProcedureOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return $"if object_id('{SchemaName}.{Name}', 'P') is not null or object_id('{SchemaName}.{Name}', 'PC') is not null{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"drop procedure [{SchemaName}].[{Name}]";
		}
	}
}
