using System;
using System.Collections;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class UpdateRowOperation : Operation
	{
		// Update Specific Row
		public UpdateRowOperation(string schemaName, string tableName, Hashtable column, string where, bool useRawValues)
		{
			All = false;
			SchemaName = schemaName;
			TableName = tableName;
			Column = column;
			Where = where;
			UseRawValues = useRawValues;
		}

		// Update All Rows
		public UpdateRowOperation(string schemaName, string tableName, Hashtable column, bool useRawValues) 
		{
			All = true;
			SchemaName = schemaName;
			TableName = tableName;
			Column = column;
			UseRawValues = useRawValues;
		}

		public bool All { get; set; }

		public Hashtable Column { get; set; }

		public override OperationQueryType QueryType => OperationQueryType.NonQuery;

		public string SchemaName { get; set; }

		public string TableName { get; set; }

		public bool UseRawValues { get; set; }

		public string Where { get; set; }

		public override string ToIdempotentQuery()
		{
			return ToQuery();
		}

		public override string ToQuery()
		{
			var columnList = new List<string>();

			foreach (DictionaryEntry de in Column)
			{
				var value = de.Value;
				var name = de.Key;
				if (value == null)
				{
					value = "null";
				}
				else if (value is Boolean)
				{
					value = ((bool)value) ? "1" : "0";
				}
				else if (UseRawValues)
				{
					value = value.ToString();
				}
				else if (value is DateTime || value is TimeSpan)
				{
					value = string.Format("'{0}'", value);
				}
				else if (value is string || value is char)
				{
					value = string.Format("'{0}'", value.ToString().Replace("'", "''"));
				}
				else
				{
					value = value.ToString();
				}
				columnList.Add(String.Format("[{0}] = {1}", name, value));
			}
			var columnClause = String.Join(", ", columnList.ToArray());

			var whereClause = "";
			if (! All)
			{
				whereClause = String.Format(" where {0}", Where);
			}

			return String.Format("update [{0}].[{1}] set {2}{3}", SchemaName, TableName, columnClause, whereClause);
		}
	}
}