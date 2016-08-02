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
					"if not exists (select * from sys.indexes where name = '{0}' and object_id = object_id('{1}.{2}', 'U')) or{3}" +
					"   {4} != (select count(*) from sys.indexes i join sys.index_columns ic on i.object_id = ic.object_id join sys.columns c on i.object_id=c.object_id and ic.column_id = c.column_id where i.name = '{0}' and i.object_id =  object_id('{1}.{2}','U')) or{3}" +
					"   {4} != (select count(*) from sys.indexes i join sys.index_columns ic on i.object_id = ic.object_id join sys.columns c on i.object_id=c.object_id and ic.column_id = c.column_id where i.name = '{0}' and i.object_id =  object_id('{1}.{2}','U') and c.name in ('{5}')){3}" +
					"begin{3}" +
					"\tif exists(select * from sys.indexes where name = '{0}' and object_id = object_id('{1}.{2}', 'U')){3}" +
					"\t\talter table [{1}].[{2}] drop constraint [{0}]{3}" +
					"{3}" +
					"\t{6}{3}" +
					"end{3}",
					Name, SchemaName, TableName, Environment.NewLine, ColumnName.Count, string.Join("','", ColumnName.ToArray()), ToQuery());
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
