using System;

namespace Rivet.Operations
{
	public sealed class AddPrimaryKeyOperation : TableObjectOperation
	{
		//System Generated Constraint Name
		public AddPrimaryKeyOperation(string schemaName, string tableName, string [] columnName, bool nonClustered, string[] options)
			: base(schemaName, tableName, new ConstraintName(schemaName, tableName, columnName, ConstraintType.PrimaryKey).ToString())
		{
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
		public AddPrimaryKeyOperation(string schemaName, string tableName, string[] columnName, string customConstraintName, bool nonClustered, string[] options)
			: base(schemaName, tableName, customConstraintName)
		{
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

		public string[] ColumnName { get; private set; }
		public bool NonClustered { get; private set; }
		public string[] Options { get; private set; }

		public override string ToIdempotentQuery()
		{
			return
				String.Format(
					"if not exists (select * from sys.indexes where name = '{0}' and object_id = object_id('{1}.{2}', 'U')){3}\t{4}",
					Name, SchemaName, TableName, Environment.NewLine, ToQuery());
		}

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

			var columnClause = string.Join("], [", ColumnName);

			return string.Format("alter table [{0}].[{1}] add constraint [{2}] primary key {3} ([{4}]){5}", 
				SchemaName, TableName, Name, clusteredClause, columnClause, optionClause);
		}
	}
}
