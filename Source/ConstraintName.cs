using System;
using System.Collections.Generic;

namespace Rivet
{
	public enum ConstraintType 
	{
		Default,
		PrimaryKey,
		ForeignKey,
		Check,
		Index,
		UniqueKey,
		UniqueIndex
	}

	public class ConstraintName
	{
		private readonly string _name;

		public ConstraintName(string schemaName, string tableName, string[] columnName, ConstraintType type)
		{
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = new List<string>(columnName ?? new string[0]);
			Type = type;
		}

		public ConstraintName(string name)
		{
			_name = name;
		}

		public string SchemaName { get; set; }
		public string TableName { get; set; }
		public List<string> ColumnName { get; private set; }
		public ConstraintType Type { get; set; }
		public string Name { get { return ToString(); } }

		public override string ToString()
		{
			if (!string.IsNullOrEmpty(_name))
				return _name;

			string keyname;
			switch(Type)
			{
				case ConstraintType.Default:
					keyname = "DF";
					break;

				case ConstraintType.PrimaryKey:
					keyname = "PK";
					break;

				case ConstraintType.Check:
					keyname = "CK";
					break;

				case ConstraintType.Index:
					keyname = "IX";
					break;

				case ConstraintType.UniqueKey:
					keyname = "AK";
					break;

				case ConstraintType.UniqueIndex:
					keyname = "UIX";
					break;

				default:
					keyname = "DF";
					break;
			}
			
			var columnClause = string.Join("_", ColumnName.ToArray());
			columnClause = String.Format("_{0}", columnClause);

			if( Type == ConstraintType.PrimaryKey )
			{
				columnClause = "";
			}

			var name = string.Format("{0}_{1}_{2}{3}", keyname, SchemaName, TableName, columnClause);
			if (string.Equals(SchemaName, "dbo", StringComparison.InvariantCultureIgnoreCase))
			{
				name = string.Format("{0}_{1}{2}", keyname, TableName, columnClause);
			}

			return name;
		}
	}
}