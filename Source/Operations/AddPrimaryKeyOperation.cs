namespace Rivet.Operations
{
	public sealed class AddPrimaryKeyOperation : Operation
	{
		//System Generated Constraint Name
		public AddPrimaryKeyOperation(string schemaName, string tableName, string [] columnName, bool nonClustered,
		                              string[] options)
		{
			ConstraintName = new ConstraintName(schemaName, tableName, columnName, ConstraintType.PrimaryKey);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
			NonClustered = nonClustered;
			if (options != null)
			{
				Options = (string[])options.Clone();
			}
			else
			{
				Options = null;
			}
		}

		//Custom Constraint Name
		public AddPrimaryKeyOperation(string schemaName, string tableName, string[] columnName, string customConstraintName, bool nonClustered,
							  string[] options)
		{
			ConstraintName = new ConstraintName(customConstraintName);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = (string[])columnName.Clone();
			NonClustered = nonClustered;
			if (options != null)
			{
				Options = (string[])options.Clone();
			}
			else
			{
				Options = null;
			}
		}

		public ConstraintName ConstraintName { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }
		public bool NonClustered { get; private set; }
		public string[] Options { get; private set; }

		public override string ToQuery()
		{
			var clusteredClause = "clustered";
			if (NonClustered)
			{
				clusteredClause = "nonclustered";
			}

			var optionClause = "";
			if (!(Options == null || Options.Length == 0))
			{
				optionClause = string.Join(", ", Options);
				optionClause = string.Format(" with ( {0} )", optionClause);
			}

			var columnClause = string.Join(",", ColumnName);

			return string.Format("alter table [{0}].[{1}] add constraint [{2}] primary key {3} ({4}){5}", 
				SchemaName, TableName, ConstraintName.ToString(), clusteredClause, columnClause, optionClause);
		}
	}
}
