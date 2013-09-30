using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

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

		public int Count()
		{
			return Column.Length;
		}

		public override string ToQuery()
		{
			var insertclause = new StringBuilder();
			var query = new StringBuilder();
			insertclause.AppendFormat("insert into [{0}].[{1}]", SchemaName, TableName);

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

				query.AppendFormat("{0} {1} values {2};", insertclause, columnClause, valueClause);
				query.AppendLine();
			}

			return query.ToString();
		}
	}


}