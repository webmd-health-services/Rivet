using System;

namespace Rivet.Operations
{
	public sealed class RemoveExtendedPropertyOperation : Operation
	{
		// Schema
		public RemoveExtendedPropertyOperation(string schemaName, string name)
		{
			ForSchema = true;
			SchemaName = schemaName;
			Name = name;
		}

		// Table
		public RemoveExtendedPropertyOperation(string schemaName, string tableName, string name)
		{
			ForTable = true;
			SchemaName = schemaName;
			TableName = tableName;
			Name = name;
		}

		// Column
		public RemoveExtendedPropertyOperation(string schemaName, string tableName, string columnName, string name)
		{
			ForColumn = true;
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = columnName;
			Name = name;
		}

		public bool ForSchema { get; private set; }
		public bool ForTable { get; private set; }
		public bool ForColumn { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ColumnName { get; private set; }
		public string Name { get; private set; }

		public override string ToQuery()
		{
			var query = string.Format(@"EXEC sys.sp_dropextendedproperty{2}@name=N'{0}',{2}@level0type=N'SCHEMA', @level0name=N'{1}'", Name, SchemaName, Environment.NewLine);

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
