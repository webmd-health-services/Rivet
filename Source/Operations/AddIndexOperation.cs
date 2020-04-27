using System;
using System.Collections.Generic;

namespace Rivet.Operations
{
	[ObjectRemovedByOperation(typeof(RemoveIndexOperation))]
	public sealed class AddIndexOperation : TableObjectOperation
	{
		// All Columns ASC
		public AddIndexOperation(string schemaName, string tableName, string name, string[] columnName, 
			bool unique, bool clustered, string[] options, string where, string on, string fileStreamOn, string[] include) 
			: base(schemaName, tableName, name)
		{
			ColumnName = new List<string>(columnName ?? new string[0]);
			Unique = unique;
			Clustered = clustered;
			Options = new List<string>(options ?? new string[0]);
			Where = where;
			On = on;
			FileStreamOn = fileStreamOn;
			Descending = new bool[0];
			Include = new List<string>(include ?? new string[0]);
		}

		// Some Columns DESC
		public AddIndexOperation(string schemaName, string tableName, string name, string[] columnName, bool[] descending,
			bool unique, bool clustered, string[] options, string where, string on, string fileStreamOn, string[] include)
			: this(schemaName, tableName, name, columnName, unique, clustered, options, where, on, fileStreamOn, include)
		{
			Descending = descending ?? new bool[0];
		}

		public bool Clustered { get; set; }

		public List<string> ColumnName { get; }

		public bool[] Descending { get; set; }

		public string FileStreamOn { get; set; }

		public List<string> Include { get; set; }

		public string On { get; set; }

		public List<string> Options { get; }

		public string Where { get; set; }

		public bool Unique { get; set; }

		public override string ToIdempotentQuery()
		{
			return $"if not exists (select * from sys.indexes where name = '{Name}' and (object_id = object_id('{SchemaName}.{TableName}', 'U') or object_id = object_id('{SchemaName}.{TableName}', 'V'))){Environment.NewLine}" +
				   $"    {ToQuery()}";
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
				optionsClause = $" with ( {optionsClause} )";
			}

			var includeClause = "";
			if (Include.Count > 0)
			{
				for( var idx = 0; idx < Include.Count; idx++ )
				{
					Include[idx] = $"[{Include[idx]}]";
				}
				includeClause = string.Join(", ", Include.ToArray());
				includeClause = $" include ( {includeClause} )";
			}

			var whereClause = "";
			if (!string.IsNullOrEmpty(Where))
			{
				whereClause = $" where ( {Where} )";
			}

			var onClause = "";
			if (!string.IsNullOrEmpty(On))
			{
				onClause = $" on {On}";
			}

			var fileStreamClause = "";
			if (!string.IsNullOrEmpty(FileStreamOn))
			{
				// ReSharper disable once StringLiteralTypo
				fileStreamClause = $" filestream_on {FileStreamOn}";
			}

			for( var idx = 0; idx < ColumnName.Count; idx++ )
			{
				var modifier = "";
				if( idx < Descending.Length && Descending[idx] )
				{
					modifier = " desc";
				}
				ColumnName[idx] = $"[{ColumnName[idx]}]{modifier}";
			}

			var columnClause = string.Join(", ", ColumnName.ToArray());

			var query =
				$"create{uniqueClause}{clusteredClause} index [{Name}] on [{SchemaName}].[{TableName}] ({columnClause}){includeClause}{optionsClause}{whereClause}{onClause}{fileStreamClause}";
			return query;
		}
	}
}
