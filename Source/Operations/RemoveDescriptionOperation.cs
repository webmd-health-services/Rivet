using System;

namespace Rivet.Operations
{
	public sealed class RemoveDescriptionOperation  : Operation
	{
		public RemoveDescriptionOperation(string schemaName, string tableName, string columnName)
		{
			ForColumn = true;
			SchemaName = schemaName;
			TableName = tableName;
			ColumnName = columnName;
		}

		public RemoveDescriptionOperation(string schemaName, string tableName)
		{
			ForTable = true;
			SchemaName = schemaName;
			TableName = tableName;
		}

		public bool ForColumn { get; private set; }
		public bool ForTable { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string ColumnName { get; private set; }

		public override string ToQuery()
		{
			var query = string.Format(@"
			EXEC sys.sp_dropextendedproperty	@name=N'MS_Description',
												@level0type=N'SCHEMA', @level0name='{0}',
												@level1type=N'TABLE',  @level1name='{1}'", SchemaName, TableName);

			if (ForTable == false && ForColumn == true && !string.IsNullOrEmpty(ColumnName))
			{
				query += string.Format(",\n												@level2type=N'COLUMN', @level2name='{0}'", ColumnName);
			}

			return query;
		}
	}
}
