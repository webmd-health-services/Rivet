using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Rivet.Operations
{
	public sealed class AddRowOperation : Operation
	{
		public AddRowOperation(string schemaName, string tableName, Hashtable[] column) : this( schemaName, tableName, column, false)
		{
			SchemaName = schemaName;
			TableName = tableName;
			Column = column;
		}

		public AddRowOperation(string schemaName, string tableName, Hashtable[] column, bool identityInsert)
		{
			SchemaName = schemaName;
			TableName = tableName;
			Column = column;
			IdentityInsert = identityInsert;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public Hashtable[] Column { get; private set; }
		public bool IdentityInsert { get; private set; }

		public int Count
		{
			get { return Column.Length; }
		}

		public override string ToQuery()
		{
			var query = new StringBuilder();

			if (IdentityInsert)
			{
				query.AppendFormat("set IDENTITY_INSERT [{0}].[{1}] on", SchemaName, TableName);
				query.AppendLine();
			}


			foreach (var row in Column)
			{
				var columnList = row.Keys.Cast<string>().ToList();
				var columnClause = String.Join(", ", columnList.ToArray());
				columnClause = String.Format("({0})", columnClause);

				var valueList = new List<string>();
				foreach (DictionaryEntry de in row)
				{
					if (de.Value == null)
					{
						valueList.Add("null");
					}
					else if (de.Value is Boolean)
					{
						valueList.Add(((bool)de.Value) ? "1" : "0");
					}
					else if (de.Value is string || de.Value is char)
					{
						var temp = String.Format("'{0}'", de.Value.ToString().Replace("'", "''"));
						valueList.Add(temp);
					}
					else if (de.Value is DateTime || de.Value is TimeSpan )
					{
						var temp = String.Format("'{0}'", de.Value);
						valueList.Add(temp);
					}
					else
					{
						valueList.Add(de.Value.ToString());
					}
				}
				var valueClause = String.Join(", ", valueList.ToArray());
				valueClause = String.Format("({0})", valueClause);

				query.AppendFormat("insert into [{0}].[{1}] {2} values {3}", SchemaName, TableName, columnClause, valueClause);
				query.AppendLine();
			}

			if (IdentityInsert)
			{
				query.AppendFormat("set IDENTITY_INSERT [{0}].[{1}] off", SchemaName, TableName);
				query.AppendLine();
			}

			return query.ToString();
		}
	}


}