using System;

namespace Rivet.Operations
{
	public sealed class EnableConstraintOperation : TableObjectOperation
	{
		public EnableConstraintOperation(string schemaName, string tableName, string name, bool withNoCheck)
			: base(schemaName, tableName, name)
		{
			WithNoCheck = withNoCheck;
		}

		public bool WithNoCheck { get; set; }

		public override string ToIdempotentQuery()
		{
			return $"if objectproperty (object_id('{SchemaName}.{Name}'), 'CnstIsDisabled') = 1{Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			var withNoCheckClause = (WithNoCheck) ? "" : " with nocheck";

			return $"alter table [{SchemaName}].[{TableName}]{withNoCheckClause} check constraint [{Name}]";
		}
	}
}
