namespace Rivet.Operations
{
	public sealed class AddCheckConstraintOperation : Operation
	{
		public AddCheckConstraintOperation(string schemaName, string tableName, string constraintName, string expression, bool notForReplication)
		{
			ConstraintName = constraintName;
			SchemaName = schemaName;
			TableName = tableName;
			Expression = expression;
			NotForReplication = notForReplication;
		}

		public string ConstraintName { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string Expression { get; private set; }
		public bool NotForReplication { get; private set; }

		public override string ToQuery()
		{
			var notForReplicationclause = "";
			if (NotForReplication)
			{
				notForReplicationclause = " not for replication";
			}

			return string.Format("alter table [{0}].[{1}] add constraint [{2}] check{4} ({3}) ",
				SchemaName, TableName, ConstraintName, Expression, notForReplicationclause);
		}
	}
}
