namespace Rivet.Operations
{
	public sealed class RemoveCheckConstraintOperation : Operation
	{
		public RemoveCheckConstraintOperation(string schemaName, string tableName, string constraintName)
		{

			SchemaName = schemaName;
			TableName = tableName;
			ConstraintName = constraintName;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ConstraintName { get; private set; }

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] drop constraint [{2}]", SchemaName, TableName, ConstraintName);
		}
	}
}
