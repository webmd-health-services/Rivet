using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Rivet.Operations
{
	public sealed class AddRowOperation : Operation
	{
		public AddRowOperation(string schemaName, string tableName, Hashtable[] column)
		{
			SchemaName = schemaName;
			TableName = tableName;
			Column = column;

		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public Hashtable[] Column { get; private set; }


		public override string ToQuery()
		{
			var query = "";
			var insertclause = string.Format("insert into [{0}].[{1}]", SchemaName, TableName);

			foreach (var row in Column)
			{
				var columnList = row.Keys.Cast<string>().ToList();
				var columnClause = String.Join(", ", columnList.ToArray());
				columnClause = String.Format("({0})", columnClause);

				var valueList = new List<string>();
				foreach (DictionaryEntry de in row)
				{
					if (de.Value is int)
					{
						valueList.Add(de.Value.ToString());
					}
					else
					{
						var temp = String.Format("'{0}'", de.Value);
						valueList.Add(temp);
					}
				}
				var valueClause = String.Join(", ", valueList.ToArray());
				valueClause = String.Format("({0})", valueClause);

				query = String.Format("{0}{1} {2} values {3}; ", query, insertclause, columnClause, valueClause);
			}

			return query;
		}
	}


}