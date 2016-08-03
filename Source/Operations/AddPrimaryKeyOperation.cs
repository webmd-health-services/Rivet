using System;
using System.Collections.Generic;
using System.Linq;

namespace Rivet.Operations
{
	public sealed class AddPrimaryKeyOperation : ConstraintOperation
	{
		//System Generated Constraint Name
		public AddPrimaryKeyOperation(string schemaName, string tableName, string [] columnName, bool nonClustered, string[] options)
			: base(schemaName, tableName, new ConstraintName(schemaName, tableName, columnName, ConstraintType.PrimaryKey).ToString(), ConstraintType.PrimaryKey)
		{
		    ColumnName = new List<string>(columnName);
			NonClustered = nonClustered;
			if (options != null)
			{
			    Options = new List<string>(options);
			}
			else
			{
				Options = null;
			}
		}

		//Custom Constraint Name
		public AddPrimaryKeyOperation(string schemaName, string tableName, string[] columnName, string customConstraintName, bool nonClustered, string[] options)
			: base(schemaName, tableName, customConstraintName, ConstraintType.PrimaryKey)
		{
            ColumnName = new List<string>(columnName);
			NonClustered = nonClustered;
			if (options != null)
			{
                Options = new List<string>(options);
			}
			else
			{
				Options = null;
			}
		}

		public List<string> ColumnName { get; set; }
		public bool NonClustered { get; set; }
        public List<string> Options { get; set; }

		public override string ToIdempotentQuery()
		{
			return
				String.Format(
					"if not exists (select * from sys.indexes where name = '{0}' and object_id = object_id('{1}.{2}', 'U')){3}\t{4}", Name, SchemaName, TableName, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			var clusteredClause = "clustered";
			if (NonClustered)
			{
				clusteredClause = "nonclustered";
			}

			var optionClause = "";
			if (!(Options == null || Options.Count == 0))
			{
				optionClause = string.Join(", ", Options.ToArray());
				optionClause = string.Format(" with ( {0} )", optionClause);
			}

			var columnClause = string.Join("], [", ColumnName.ToArray());

			return string.Format("alter table [{0}].[{1}] add constraint [{2}] primary key {3} ([{4}]){5}", 
				SchemaName, TableName, Name, clusteredClause, columnClause, optionClause);
		}
	}
}
