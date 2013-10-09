using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Rivet.Operations
{
	public sealed class UpdateExtendedPropertyOperation : Operation
	{
		public UpdateExtendedPropertyOperation(string schemaName, string tableName, string description)
		{
			ForTable = true;
			SchemaName = schemaName;
			TableName = tableName;
			Description = description;
		}

		public UpdateExtendedPropertyOperation(string schemaName, string tableName, string columnName, string description)
		{
			ForColumn = true;
			SchemaName = schemaName;
			TableName = tableName;
			Description = description;
			ColumnName = columnName;
		}

		public bool ForColumn { get; private set; }
		public bool ForTable { get; private set; }
		public string SchemaName { get; private set; }
		public string TableName { get; private set; }
		public string Description { get; private set; }
		public string ColumnName { get; private set; }

		public override string ToQuery()
		{
			var query = string.Format(@"
			EXEC sys.sp_updateextendedproperty	@name=N'MS_Description',
												@value='{0}',
												@level0type=N'SCHEMA', @level0name='{1}', 
												@level1type=N'TABLE',  @level1name='{2}'", Description.Replace("'", "''"), SchemaName, TableName);
			if (ForTable == false && ForColumn == true && !string.IsNullOrEmpty(ColumnName))
			{
				query += string.Format(",\n												@level2type=N'COLUMN', @level2name='{0}'", ColumnName);
			}

			return query;
		}
	}
}
