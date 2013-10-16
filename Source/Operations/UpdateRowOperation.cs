using System;
using System.Collections;
using System.Collections.Generic;

namespace Rivet.Operations
{
	public sealed class UpdateRowOperation : Operation
	{
		// Update Specific Row
		public UpdateRowOperation(string schemaName, string tableName, Hashtable column, string where)
		{
			All = false;
			SchemaName = schemaName;
			TableName = tableName;
			Column = column;
			Where = where;
		}

		// Update All Rows
		public UpdateRowOperation(string schemaName, string tableName, Hashtable column)
		{
			All = true;
			SchemaName = schemaName;
			TableName = tableName;
			Column = column;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public Hashtable Column { get; private set; }
		public string Where { get; private set; }
		public bool All { get; private set; }


		public override string ToQuery()
		{
			var query = "";
			var columnList = new List<string>();

			foreach (DictionaryEntry kv in Column)
			{
				string element;
				if (kv.Value is int)
				{
					element = String.Format("{0} = {1}", kv.Key, kv.Value);
				}
				else
				{
					element = String.Format("{0} = '{1}'", kv.Key, kv.Value);
				}
				columnList.Add(element);
			}
			var columnClause = String.Join(", ", columnList.ToArray());

			switch (All)
			{
				case false: //Update Specific Rows
					query = String.Format("update [{0}].[{1}] set {2} where {3};", SchemaName, TableName, columnClause, Where);
					break;
				case true: //Update All Rows
					query = String.Format("update [{0}].[{1}] set {2};", SchemaName, TableName, columnClause);
					break;
			}

			return query;
		}
	}
}