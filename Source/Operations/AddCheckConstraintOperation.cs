using System;

namespace Rivet.Operations
{
	public sealed class AddCheckConstraintOperation : TableObjectOperation
	{
		public AddCheckConstraintOperation(string schemaName, string tableName, string name, string expression, bool notForReplication, bool withNoCheck) 
			:base(schemaName, tableName, name)
		{
			Expression = expression;
			NotForReplication = notForReplication;
			WithNoCheck = withNoCheck;
		}

		public string Expression { get; set; }
		public bool NotForReplication { get; set; }
		public bool WithNoCheck { get; set; }

		public override string ToIdempotentQuery()
		{
			return String.Format("if object_id('{0}.{1}', 'C') is null{2}\t{3}", SchemaName, Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			var notForReplicationclause = "";
			if (NotForReplication)
			{
				notForReplicationclause = " not for replication";
			}

			var withNoCheckClause = "";
			if (WithNoCheck)
			{
				withNoCheckClause = " with nocheck";
			}

			return string.Format("alter table [{0}].[{1}]{2} add constraint [{3}] check{4} ({5})",
				SchemaName, TableName, withNoCheckClause, Name, notForReplicationclause, Expression);
		}
	}
}
