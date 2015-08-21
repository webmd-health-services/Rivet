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

		public override string ToQuery()
		{
			return string.Format("alter table [{0}].[{1}] alter column [{2}] drop rowguidcol", SchemaName, TableName, ColumnName);
		}

		public override string ToIdempotentQuery()
		{
			return
				string.Format(
					"if( exists(select * from sys.schemas s inner join sys.tables t on s.schema_id=t.schema_id inner join sys.columns c on c.object_id = t.object_id where s.name = '{0}' and t.name = '{1}' and c.name = '{2}' and c.is_rowguidcol = 1) ){3}\t{4}",
					SchemaName, TableName, ColumnName, Environment.NewLine, ToQuery());
		}
	}
}
