using System;

namespace Rivet.Operations
{
	public sealed class AddPrimaryKeyOperation : Operation
	{
		public AddPrimaryKeyOperation(string schemaName, string tableName, string [] columnName, bool nonClustered,
		                              string[] options)
		{
			Cons = new ConstraintName(schemaName, tableName, columnName, ConstraintType.PrimaryKey);
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

		public ConstraintName Cons { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string[] ColumnName { get; private set; }
		public bool NonClustered { get; private set; }
		public string[] Options { get; private set; }

		public override string ToQuery()
		{
			var ClusteredClause = "clustered";
			if (NonClustered)
			{
				ClusteredClause = "nonclustered";
			}

			var OptionClause = "";
			if (!(Options == null || Options.Length == 0))
			{
				OptionClause = string.Join(", ", Options);
				OptionClause = string.Format(" with ( {0} )", OptionClause);
			}

			var ColumnClause = string.Join(",", ColumnName);

			return string.Format("alter table [{0}].[{1}] add constraint {2} primary key {3} ({4}){5}", 
				SchemaName, TableName, Cons.ReturnConstraintName(), ClusteredClause, ColumnClause, OptionClause);
		}
	}
}
