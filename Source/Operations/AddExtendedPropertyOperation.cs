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

		// Table
		public AddExtendedPropertyOperation(string schemaName, string tableName, string name, object value) : this(schemaName, name, value)
		{
			ForTable = true;
			TableName = tableName;
		}

		// Column
		public AddExtendedPropertyOperation(string schemaName, string tableName, string columnName, string name, object value) : this(schemaName, tableName, name, value)
		{
			ForColumn = true;
			ColumnName = columnName;
		}

		public bool ForSchema { get; private set; }
		public bool ForTable { get; private set; }
		public bool ForColumn { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ColumnName { get; private set; }
		public string Value { get; private set; }
		public string Name { get; private set; }

		public override string ToQuery()
		{
			var propertyValue = (Value == null) ? "null" : string.Format("N'{0}'", Value.Replace("'", "''"));
			var query = string.Format(@"EXEC sys.sp_addextendedproperty{3}@name=N'{0}',{3}@value={1},{3}@level0type=N'SCHEMA', @level0name=N'{2}'", Name, propertyValue, SchemaName, Environment.NewLine);

			if (ForTable || ForColumn)
			{
				query += string.Format(",{1}@level1type=N'TABLE', @level1name='{0}'", TableName, Environment.NewLine);
			}

			if (ForColumn)
			{
				query += string.Format(",{1}@level2type=N'COLUMN', @level2name='{0}'", ColumnName, Environment.NewLine);
			}
			
			return query;
		}
	}
}
