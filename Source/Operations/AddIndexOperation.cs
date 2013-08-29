using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddIndexOperation : Operation
	{
		public AddIndexOperation(string schemaName, string tableName, string [] columnName, bool unique, bool clustered,
		                         string[] options, string where, string on, string fileStreamOn)
		{
			ConstraintName = new ConstraintName(schemaName, tableName, columnName, ConstraintType.Index);
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = new List<string>(columnName ?? new string[0]);
			Unique = unique;
			Clustered = clustered;
			Options = new List<string>(options ?? new string[0]);
			Where = where;
			On = on;
			FileStreamOn = fileStreamOn;
		}

		public ConstraintName ConstraintName { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public List<string> ColumnName { get; private set; }
		public bool Unique { get; private set; }
		public bool Clustered { get; private set; }
		public List<string> Options { get; private set; }
		public string Where { get; private set; }
		public string On { get; private set; }
		public string FileStreamOn { get; private set; }

		public override string ToQuery()
		{
			var uniqueClause = "";
			if (Unique)
			{
				uniqueClause = "unique ";
			}

			var clusteredClause = "";
			if (Clustered)
			{
				clusteredClause = "clustered";
			}

			var optionsClause = "";
			if (Options.Count > 0)
			{
				optionsClause = string.Join(", ", Options.ToArray());
				optionsClause = string.Format("with ( {0} )", optionsClause);
			}

			var whereClause = "";
			if (!string.IsNullOrEmpty(Where))
			{
				whereClause = string.Format("where ( {0} )", Where);
			}

			var onClause = "";
			if (!string.IsNullOrEmpty(On))
			{
				onClause = string.Format("on {0}", On);
			}

			var fileStreamClause = "";
			if (!string.IsNullOrEmpty(FileStreamOn))
			{
				fileStreamClause = string.Format("filestream_on {0}", FileStreamOn);
			}

			var columnClause = string.Join(",", ColumnName.ToArray());

			var query = string.Format(@"create {0}{1} index {2} on [{3}].[{4}] ({5}) {6} {7} {8} {9}", 
						uniqueClause, clusteredClause, ConstraintName.ToString(), SchemaName, TableName, columnClause, optionsClause, whereClause, onClause, fileStreamClause);

			return query;
		}
	}
}
