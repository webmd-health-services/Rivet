using System;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveCheckConstraintOperation))]
	public sealed class AddCheckConstraintOperation : ConstraintOperation
	{
		public AddCheckConstraintOperation(string schemaName, string tableName, string name, string expression, bool notForReplication, bool withNoCheck) 
			:base(schemaName, tableName, name, ConstraintType.Check)
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
			return $"if object_id('{SchemaName}.{Name}', 'C') is null{Environment.NewLine}" +
				   $"    {ToQuery()}";
		}

		public override string ToQuery()
		{
			var notForReplicationClause = "";
			if (NotForReplication)
			{
				notForReplicationClause = " not for replication";
			}

			var withNoCheckClause = "";
			if (WithNoCheck)
			{
				withNoCheckClause = " with nocheck";
			}

			return $"alter table [{SchemaName}].[{TableName}]{withNoCheckClause} add constraint [{Name}] check{notForReplicationClause} ({Expression})";
		}
	}
}
