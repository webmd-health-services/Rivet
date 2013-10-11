﻿using System;
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
		Unique
	}

	public class ConstraintName
	{
		public ConstraintName(string schemaName, string tableName, string[] columnName, ConstraintType type)
		{
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = new List<string>(columnName ?? new string[0]);
			Type = type;
		}

		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public List<string> ColumnName { get; private set; }
		public ConstraintType Type { get; private set; }
		public string Name { get { return ToString(); } }

		public override string ToString()
		{
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

				case ConstraintType.Unique:
					keyname = "UQ";
					break;

				default:
					keyname = "DF";
					break;
			}
			
			var columnClause = string.Join("_", ColumnName.ToArray());
			var name = string.Format("{0}_{1}_{2}_{3}", keyname, SchemaName, TableName, columnClause);
			if (string.Equals(SchemaName, "dbo", StringComparison.InvariantCultureIgnoreCase))
			{
				name = string.Format("{0}_{1}_{2}", keyname, TableName, columnClause);
			}

			return name;
		}
	}
}