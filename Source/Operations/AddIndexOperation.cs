using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddIndexOperation : Operation
	{
		public AddIndexOperation(string schemaName, string tableName, string [] columnName, bool unique, bool clustered,
		                         string[] options, string where, string on, string fileStreamOn)
		{
			Cons = new ConstraintName(schemaName, tableName, columnName, ConstraintType.Index);
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

		public ConstraintName Cons { get; private set; }
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
			var UniqueClause = "";
			if (Unique)
			{
				UniqueClause = "unique ";
			}

			var ClusteredClause = "";
			if (Clustered)
			{
				ClusteredClause = "clustered";
			}

			var OptionsClause = "";
			if (Options.Count > 0)
			{
				OptionsClause = string.Join(", ", Options.ToArray());
				OptionsClause = string.Format("with ( {0} )", OptionsClause);
			}

			var WhereClause = "";
			if (!string.IsNullOrEmpty(Where))
			{
				WhereClause = string.Format("where ( {0} )", Where);
			}

			var OnClause = "";
			if (!string.IsNullOrEmpty(On))
			{
				OnClause = string.Format("on {0}", On);
			}

			var FileStreamClause = "";
			if (!string.IsNullOrEmpty(FileStreamOn))
			{
				FileStreamClause = string.Format("filestream_on {0}", FileStreamOn);
			}

			var ColumnClause = string.Join(",", ColumnName.ToArray());

			var query = string.Format(@"create {0}{1} index {2} on {3}.{4} ({5}) {6} {7} {8} {9}", 
						UniqueClause, ClusteredClause, Cons.ReturnConstraintName(), SchemaName, TableName, ColumnClause, OptionsClause, WhereClause, OnClause, FileStreamClause);

			return query;
		}
	}
}
