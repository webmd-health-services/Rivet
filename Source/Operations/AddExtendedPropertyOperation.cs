using System;

namespace Rivet.Operations
{
	public sealed class AddExtendedPropertyOperation : Operation
	{
		// Schema
		public AddExtendedPropertyOperation(string schemaName, string name, object value)
		{
			ForSchema = true;
			SchemaName = schemaName;
			Name = name;
			Value = (value == null) ? null : value.ToString();
		}

		// Table or View
		public AddExtendedPropertyOperation(string schemaName, string tableViewName, string name, object value, bool forView) : this(schemaName, name, value)
		{
			if (forView)
			{
				ForView = true;
			}
			else
			{
				ForTable = true;
			}
			TableViewName = tableViewName;
		}

		// Column
		public AddExtendedPropertyOperation(string schemaName, string tableViewName, string columnName, string name, object value, bool forView) : this(schemaName, tableViewName, name, value, forView)
		{
			ForColumn = true;
			ColumnName = columnName;
		}

		public bool ForSchema { get; private set; }
		public bool ForTable { get; private set; }
		public bool ForView { get; private set; }
		public bool ForColumn { get; private set; }
		public string SchemaName { get; private set; }
		public string TableViewName { get; private set; }
		public string ColumnName { get; private set; }
		public string Value { get; private set; }
		public string Name { get; private set; }

		public override string ToIdempotentQuery()
		{
			var level1Type = "null";
			var level1Name = "null";
			var level2Type = "null";
			var level2Name = "null";

			if (ForTable)
			{
				level1Type = "'TABLE'";
				level1Name = string.Format("'{0}'", TableViewName);
			}

			if (ForView)
			{
				level1Type = "'VIEW'";
				level1Name = string.Format("'{0}'", TableViewName);
			}

			if (ForColumn)
			{
				level2Type = "'COLUMN'";
				level2Name = string.Format("'{0}'", ColumnName);
			}

			return
				string.Format(
					"if not exists (select * from fn_listextendedproperty ('{0}', 'schema', '{1}', {2}, {3}, {4}, {5})){6}\t{7}",
					Name, SchemaName, level1Type, level1Name, level2Type, level2Name, Environment.NewLine, ToQuery());
		}

		public override string ToQuery()
		{
			var propertyValue = (Value == null) ? "null" : string.Format("N'{0}'", Value.Replace("'", "''"));
			var query = string.Format("exec sys.sp_addextendedproperty @name=N'{0}', @value={1},{3}                                @level0type=N'SCHEMA', @level0name=N'{2}'", Name, propertyValue, SchemaName, Environment.NewLine);

			if (ForTable)
			{
				query += string.Format(",{1}                                @level1type=N'TABLE', @level1name='{0}'", TableViewName, Environment.NewLine);
			}

			if (ForView)
			{
				query += string.Format(",{1}                                @level1type=N'VIEW', @level1name='{0}'", TableViewName, Environment.NewLine);
			}

			if (ForColumn)
			{
				query += string.Format(",{1}                                @level2type=N'COLUMN', @level2name='{0}'", ColumnName, Environment.NewLine);
			}
			
			return query;
		}
	}
}
