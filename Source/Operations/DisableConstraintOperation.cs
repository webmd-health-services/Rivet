using System;

namespace Rivet.Operations
{
	public sealed class DisableConstraintOperation : TableObjectOperation
	{
		public DisableConstraintOperation(string schemaName, string tableName, string name)
			: base(schemaName, tableName, name) { }

		public override string ToIdempotentQuery()
		{
			return $"if objectproperty (object_id('{SchemaName}.{Name}'), 'CnstIsDisabled') = 0{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"alter table [{SchemaName}].[{TableName}] nocheck constraint [{Name}]";
		}
	}
}
