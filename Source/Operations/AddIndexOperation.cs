using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class AddIndexOperation : TableObjectOperation
	{
		// All Columns ASC
		public AddIndexOperation(string schemaName, string tableName, string[] columnName, bool unique, bool clustered, string[] options, string where, string on, string fileStreamOn)
			: base(schemaName, tableName, new ConstraintName(schemaName, tableName, columnName, (unique) ? ConstraintType.UniqueIndex : ConstraintType.Index).ToString())
		{
			ColumnName = new List<string>(columnName ?? new string[0]);
			Unique = unique;
			Clustered = clustered;
			Options = new List<string>(options ?? new string[0]);
			Where = where;
			On = on;
			FileStreamOn = fileStreamOn;
			Descending = new bool[0];
		}

		// All Columns ASC With Custom Constraint Name
		public AddIndexOperation(string schemaName, string tableName, string[] columnName, string name, bool unique, bool clustered, string[] options, string where, string on, string fileStreamOn) 
			: this(schemaName, tableName, columnName, unique, clustered, options, where, on, fileStreamOn)
		{
			Name = name;
		}
		
		// Some Columns DESC
		public AddIndexOperation(string schemaName, string tableName, string [] columnName, bool [] descending, bool unique, bool clustered, string[] options, string where, string on, string fileStreamOn) 
			: this(schemaName, tableName, columnName, unique, clustered, options, where, on, fileStreamOn)
		{
			Descending = descending ?? new bool[0];
		}

		// Some Columns DESC With Custom Constraint Name
		public AddIndexOperation(string schemaName, string tableName, string[] columnName, string name, bool[] descending, bool unique, bool clustered, string[] options, string where, string on, string fileStreamOn)
			: this(schemaName, tableName, columnName, name, unique, clustered, options, where, on, fileStreamOn)
		{
			Descending = descending ?? new bool[0];
		}

		public List<string> ColumnName { get; private set; }
		public bool [] Descending { get; private set; }
		public bool Unique { get; private set; }
		public bool Clustered { get; private set; }
		public List<string> Options { get; private set; }
		public string Where { get; private set; }
		public string On { get; private set; }
		public string FileStreamOn { get; private set; }

		public override string ToIdempotentQuery()
		{
			return
				String.Format(
					"if not exists (select * from sys.indexes where name = '{0}' and (object_id = object_id('{1}.{2}', 'U') or object_id = object_id('{1}.{2}', 'V'))){3}\t{4}",
					Name, SchemaName, TableName, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			var uniqueClause = "";
			if (Unique)
			{
				uniqueClause = " unique";
			}

			var clusteredClause = "";
			if (Clustered)
			{
				clusteredClause = " clustered";
			}

			var optionsClause = "";
			if (Options.Count > 0)
			{
				optionsClause = string.Join(", ", Options.ToArray());
				optionsClause = string.Format(" with ( {0} )", optionsClause);
			}

			var whereClause = "";
			if (!string.IsNullOrEmpty(Where))
			{
				whereClause = string.Format(" where ( {0} )", Where);
			}

			var onClause = "";
			if (!string.IsNullOrEmpty(On))
			{
				onClause = string.Format(" on {0}", On);
			}

			var fileStreamClause = "";
			if (!string.IsNullOrEmpty(FileStreamOn))
			{
				fileStreamClause = string.Format(" filestream_on {0}", FileStreamOn);
			}

			for( var idx = 0; idx < ColumnName.Count; idx++ )
			{
				var modifier = "";
				if( idx < Descending.Length && Descending[idx] )
				{
					modifier = " desc";
				}
				ColumnName[idx] = string.Format("[{0}]{1}", ColumnName[idx], modifier);
			}

			var columnClause = string.Join(", ", ColumnName.ToArray());

			var query = string.Format("create{0}{1} index [{2}] on [{3}].[{4}] ({5}){6}{7}{8}{9}",
				uniqueClause, clusteredClause, Name, SchemaName, TableName, columnClause, optionsClause, whereClause,
				onClause, fileStreamClause);
			return query;
		}
	}
}
