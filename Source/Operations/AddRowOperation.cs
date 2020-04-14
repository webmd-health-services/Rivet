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

		public string SchemaName { get; set; }

		public string TableName { get; set; }

		public Hashtable[] Column { get; private set; }

		public bool IdentityInsert { get; set; }

		public override OperationQueryType QueryType => OperationQueryType.NonQuery;

		public int Count
		{
			get { return Column.Length; }
		}

		public override string ToIdempotentQuery()
		{
			return ToQuery(true);
		}

		public override string ToQuery()
		{
			return ToQuery(false);
		}

		private string ToQuery(bool withConditionalInserts)
		{
			var query = new StringBuilder();

			if (IdentityInsert)
			{
				query.AppendFormat("set IDENTITY_INSERT [{0}].[{1}] on", SchemaName, TableName);
			}

			foreach (var row in Column)
			{
				var columnList = row.Keys.Cast<string>().ToList();
				var columnClause = String.Join("], [", columnList.ToArray());
				columnClause = String.Format("([{0}])", columnClause);
				var whereClauses = new List<string>(row.Count);

				var valueList = new List<string>();
				foreach (DictionaryEntry de in row)
				{
					string value;
					if (de.Value == null)
					{
						value = "null";
					}
					else if (de.Value is Boolean)
					{
						value = ((bool) de.Value) ? "1" : "0";
					}
					else if (de.Value is string || de.Value is char)
					{
						value = String.Format("'{0}'", de.Value.ToString().Replace("'", "''"));
					}
					else if (de.Value is DateTime || de.Value is TimeSpan)
					{
						value = String.Format("'{0}'", de.Value);
					}
					else
					{
						value = de.Value.ToString();
					}

					var whereClause = string.Format("[{0}] = {1}", de.Key, value);
					whereClauses.Add(whereClause);
					valueList.Add(value);
				}
				var valueClause = String.Join(", ", valueList.ToArray());
				valueClause = String.Format("({0})", valueClause);

				if (query.Length > 0)
				{
					query.AppendLine();
				}

				if (withConditionalInserts)
				{
					query.AppendFormat("if not exists (select * from [{0}].[{1}] where {2}){3}\t", SchemaName, TableName,
						String.Join(" and ", whereClauses.ToArray()), Environment.NewLine);
				}
				query.AppendFormat("insert into [{0}].[{1}] {2} values {3}", SchemaName, TableName, columnClause, valueClause);
			}

			if (IdentityInsert)
			{
				query.AppendLine();
				query.AppendFormat("set IDENTITY_INSERT [{0}].[{1}] off", SchemaName, TableName);
			}

			return query.ToString();
		}
	}


}