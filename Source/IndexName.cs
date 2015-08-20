using System;
using System.Collections.Generic;

namespace Rivet
{
	public class IndexName
	{
		private readonly string _name;

		public IndexName(string schemaName, string tableName, string[] columnName, bool isUnique)
		{
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = new List<string>(columnName ?? new string[0]);
			Unique = isUnique;
		}

		public IndexName(string name)
		{
			_name = name;
		}

		public string SchemaName { get; set; }
		public string TableName { get; set; }
		public List<string> ColumnName { get; private set; }
		public bool Unique{ get; set; }
		public string Name { get { return ToString(); } }

		public override string ToString()
		{
			if (!string.IsNullOrEmpty(_name))
				return _name;

			string keyname = "IX";
			if (Unique)
			{
				keyname = "UIX";
			}

			var columnClause = string.Join("_", ColumnName.ToArray());
			columnClause = String.Format("_{0}", columnClause);

			var name = string.Format("{0}_{1}_{2}{3}", keyname, SchemaName, TableName, columnClause);
			if (string.Equals(SchemaName, "dbo", StringComparison.InvariantCultureIgnoreCase))
			{
				name = string.Format("{0}_{1}{2}", keyname, TableName, columnClause);
			}

			return name;
		}
	}
}