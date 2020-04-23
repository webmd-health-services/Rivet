using System;

namespace Rivet.Operations
{
	public sealed class RemoveUserDefinedFunctionOperation : ObjectOperation
	{
		public RemoveUserDefinedFunctionOperation(string schemaName, string name)
			: base(schemaName, name)
		{
		}

		public override string ToIdempotentQuery()
		{
			return
				$"if object_id('{SchemaName}.{Name}', 'AF') is not null or{Environment.NewLine}" + 
				$"   object_id('{SchemaName}.{Name}', 'FN') is not null or{Environment.NewLine}" +
				$"   object_id('{SchemaName}.{Name}', 'TF') is not null or{Environment.NewLine}" +
				$"   object_id('{SchemaName}.{Name}', 'FS') is not null or{Environment.NewLine}" +
				$"   object_id('{SchemaName}.{Name}', 'FT') is not null or{Environment.NewLine}" +
				$"   object_id('{SchemaName}.{Name}', 'IF') is not null{Environment.NewLine}" +
				$"    {ToIndentedQuery()}";
		}

		public override string ToQuery()
		{
			return $"drop function [{SchemaName}].[{Name}]";
		}
	}
}
