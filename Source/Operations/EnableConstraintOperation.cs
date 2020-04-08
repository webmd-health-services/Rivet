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
			return String.Format("if objectproperty (object_id('{0}.{1}'), 'CnstIsDisabled') = 1{2}\t{3}",
				SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			var withNoCheckClause = (WithNoCheck) ? "" : " with nocheck";

			return string.Format("alter table [{0}].[{1}]{2} check constraint [{3}]",
				SchemaName, TableName, withNoCheckClause, Name);
		}
	}
}
