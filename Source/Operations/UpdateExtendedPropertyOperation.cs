using System;

namespace Rivet.Operations
{
	public sealed class UpdateExtendedPropertyOperation : Operation
	{
		// Schema
		public UpdateExtendedPropertyOperation(string schemaName, string name, object value)
		{
			ForSchema = true;
			SchemaName = schemaName;
			Name = name;
			Value = (value == null) ? null : value.ToString();
		}

		// Table or View
		public UpdateExtendedPropertyOperation(string schemaName, string tableViewName, string name, object value, bool forView) : this(schemaName, name, value)
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
		public UpdateExtendedPropertyOperation(string schemaName, string tableName, string columnName, string name, object value, bool forView)
			: this(schemaName, tableName, name, value, forView)
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

		public override string ToQuery()
		{
			var propertyValue = (Value == null) ? "null" : String.Format("N'{0}'", Value.Replace("'", "''"));
			var query = string.Format(@"EXEC sys.sp_updateextendedproperty{3}@name=N'{0}',{3}@value={1},{3}@level0type=N'SCHEMA', @level0name=N'{2}'", Name, propertyValue, SchemaName, Environment.NewLine);

			if (ForTable)
			{
				query += string.Format(",{1}@level1type=N'TABLE', @level1name='{0}'", TableViewName, Environment.NewLine);
			}

			if (ForView)
			{
				query += string.Format(",{1}@level1type=N'VIEW', @level1name='{0}'", TableViewName, Environment.NewLine);
			}

			if (ForColumn)
			{
				query += string.Format(",{1}@level2type=N'COLUMN', @level2name='{0}'", ColumnName, Environment.NewLine);
			}

			return query;
		}
	}
}
