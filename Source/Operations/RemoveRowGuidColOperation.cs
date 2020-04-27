using System;

namespace Rivet.Operations
{
	public sealed class RemoveRowGuidColOperation : TableObjectOperation
	{
		public RemoveRowGuidColOperation(string schemaName, string tableName, string columnName)
			: base(schemaName, tableName, columnName)
		{
			ColumnName = columnName;
		}

		public string ColumnName { get; set; }

		public override string ToIdempotentQuery()
		{
			return
				$"if exists(select * from sys.tables t inner join sys.columns c on c.object_id = t.object_id where t.schema_id=schema_id('{SchemaName}') and t.name = '{TableName}' and c.name = '{ColumnName}' and c.is_rowguidcol = 1){Environment.NewLine}    {ToQuery()}";
		}

		public override string ToQuery()
		{
			return $"alter table [{SchemaName}].[{TableName}] alter column [{ColumnName}] drop rowguidcol";
		}
	}
}
